# frozen_string_literal: true

module Squall
  module Executors
    class ProcessExecutor < BaseExecutor
      def execute(producer, &block)
        units = producer.each_unit.to_a
        return [] if units.empty?

        chunks = slice_units(units, workers_count)
        execute_forks(chunks, &block)
      end

      private

      def slice_units(units, count)
        chunk_size = (units.size.to_f / count).ceil
        units.each_slice(chunk_size).to_a
      end

      def execute_forks(chunks, &block)
        pipes = chunks.map { IO.pipe }
        pids = spawn_workers(chunks, pipes, &block)
        collect_results(pipes, pids)
      end

      def spawn_workers(chunks, pipes, &block)
        chunks.each_with_index.map do |chunk, i|
          r, w = pipes[i]
          fork_worker(chunk, r, w, &block)
        end
      end

      def fork_worker(chunk, read_io, write_io, &block)
        fork do
          read_io.close
          RailsAdapter.establish_fork_connection
          chunk_results = chunk.map { |u| [u.index, u.process_with(block)] }
          Marshal.dump(chunk_results, write_io)
          write_io.close
          exit!(0)
        end
      rescue NotImplementedError
        chunk_results = chunk.map { |u| [u.index, u.process_with(block)] }
        Marshal.dump(chunk_results, write_io)
        0
      end

      def collect_results(pipes, pids)
        raw = pipes.map do |r, w|
          w.close
          data = Marshal.load(r) rescue []
          r.close
          data
        end
        pids.each { |pid| Process.wait(pid) if pid && pid.positive? }
        raw.flatten(1).sort_by { |idx, _| idx }.map { |_, val| val }
      end
    end
  end
end
