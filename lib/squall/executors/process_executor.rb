# frozen_string_literal: true

module Squall
  module Executors
    # Multi-process executor with IO leak prevention, PID reaping, and graceful fallback.
    # Example:
    #   executor = Squall::Executors::ProcessExecutor.new(workers_count: 4)
    #   results = executor.execute(producer) { |item| item * 2 }
    class ProcessExecutor < BaseExecutor
      def execute(producer, &block)
        return fallback_to_threads(producer, &block) unless fork_supported?

        units = producer.each_unit.to_a
        return [] if units.empty?

        chunks = slice_units(units, workers_count)
        execute_forks(chunks, &block)
      end

      private

      def fork_supported?
        Process.respond_to?(:fork)
      end

      def fallback_to_threads(producer, &block)
        ThreadExecutor.new(
          workers_count: workers_count,
          progress_monitor: progress_monitor,
          cancellation: cancellation
        ).execute(producer, &block)
      end

      def slice_units(units, count)
        chunk_size = (units.size.to_f / count).ceil
        units.each_slice(chunk_size).to_a
      end

      def execute_forks(chunks, &block)
        pipes = chunks.map { IO.pipe }
        pids = []
        begin
          pids = spawn_workers(chunks, pipes, &block)
          collect_results(pipes, pids)
        ensure
          cleanup_resources(pipes, pids)
        end
      end

      def spawn_workers(chunks, pipes, &block)
        chunks.each_with_index.map do |chunk, i|
          read_io, write_io = pipes[i]
          fork_worker(chunk, read_io, write_io, &block)
        end
      end

      def fork_worker(chunk, read_io, write_io, &block)
        fork do
          read_io.close rescue nil
          RailsAdapter.establish_fork_connection
          payload = execute_chunk_safely(chunk, &block)
          Marshal.dump(payload, write_io)
          write_io.close rescue nil
          exit!(0)
        end
      end

      def execute_chunk_safely(chunk, &block)
        [:ok, chunk.map { |u| [u.index, u.process_with(block)] }]
      rescue StandardError => e
        [:error, e.class.name, e.message]
      end

      def collect_results(pipes, pids)
        raw = pipes.map { |r, w| read_from_pipe(r, w) }
        check_and_raise_child_errors!(raw)
        raw.flat_map { |_, data| data }.sort_by { |idx, _| idx }.map { |_, val| val }
      end

      def read_from_pipe(read_io, write_io)
        write_io.close rescue nil
        Marshal.load(read_io)
      rescue StandardError
        [:ok, []]
      ensure
        read_io.close rescue nil
      end

      def check_and_raise_child_errors!(raw)
        error = raw.find { |status, _| status == :error }
        return unless error

        _, err_class, err_msg = error
        raise StandardError, "[Process Worker #{err_class}] #{err_msg}"
      end

      def cleanup_resources(pipes, pids)
        pipes.each do |r, w|
          r.close rescue nil
          w.close rescue nil
        end
        pids.compact.each do |pid|
          Process.wait(pid) rescue nil if pid.positive?
        end
      end
    end
  end
end
