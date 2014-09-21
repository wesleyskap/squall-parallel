require "thread"

module Squall
  module Executors
    class ThreadExecutor < BaseExecutor
      def execute(producer, &block)
        results = []
        queue = build_work_queue(producer)
        mutex = Mutex.new

        threads = Array.new(workers_count) do
          Thread.new { process_queue(queue, results, mutex, &block) }
        end
        threads.each(&:join)

        results.sort_by { |idx, _| idx }.map { |_, val| val }
      end

      private

      def build_work_queue(producer)
        queue = Queue.new
        producer.each_unit { |unit| queue.push(unit) }
        queue
      end

      def process_queue(queue, results, mutex, &block)
        until queue.empty?
          unit = queue.pop(true) rescue nil
          break if unit.nil?

          res = RailsAdapter.with_connection { unit.process_with(block) }
          mutex.synchronize { results << [unit.index, res] }
        end
      end
    end
  end
end
