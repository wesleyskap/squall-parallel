require "thread"

module Squall
  module Executors
    class ThreadExecutor < BaseExecutor
      def execute(producer, &block)
        results = []
        mutex = Mutex.new
        threads = []
        units = producer.each_unit.to_a
        chunk_size = (units.size.to_f / workers_count).ceil

        units.each_slice(chunk_size) do |slice|
          threads << Thread.new do
            res = slice.map { |u| [u.index, u.process_with(block)] }
            mutex.synchronize { results.concat(res) }
          end
        end
        threads.each(&:join)
        results.sort_by { |idx, _| idx }.map { |_, val| val }
      end
    end
  end
end
