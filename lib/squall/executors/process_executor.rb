module Squall
  module Executors
    class ProcessExecutor < BaseExecutor
      def execute(producer, &block)
        units = producer.each_unit.to_a
        return [] if units.empty?

        chunk_size = (units.size.to_f / workers_count).ceil
        chunks = units.each_slice(chunk_size).to_a
        pipes = chunks.map { IO.pipe }

        pids = chunks.each_with_index.map do |chunk, i|
          r, w = pipes[i]
          fork_worker(chunk, r, w, &block)
        end

        collect_results(pipes, pids)
      end

      private

      def fork_worker(chunk, read_io, write_io, &block)
        fork do
          read_io.close
          RailsAdapter.establish_fork_connection if defined?(RailsAdapter)
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
