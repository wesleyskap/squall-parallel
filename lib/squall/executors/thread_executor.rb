require "thread"

module Squall
  module Executors
    # Concurrent thread pool executor with cooperative cancellation and fail-fast semantics.
    # Example:
    #   executor = Squall::Executors::ThreadExecutor.new(workers_count: 4)
    #   results = executor.execute(producer) { |item| item * 2 }
    class ThreadExecutor < BaseExecutor
      def execute(producer, &block)
        queue = build_work_queue(producer)
        results = []
        mutex = Mutex.new
        first_error = nil

        register_queue_drain(queue)
        threads = spawn_workers(queue, results, mutex, ->(err) { first_error ||= err }, &block)
        threads.each(&:join)

        raise first_error if first_error

        results.sort_by { |idx, _| idx }.map { |_, val| val }
      end

      private

      def register_queue_drain(queue)
        cancellation.on_cancel { queue.clear rescue nil }
      end

      def build_work_queue(producer)
        queue = Queue.new
        producer.each_unit { |unit| queue.push(unit) }
        queue
      end

      def spawn_workers(queue, results, mutex, on_error, &block)
        Array.new(workers_count) do
          Thread.new { work_loop(queue, results, mutex, on_error, &block) }
        end
      end

      def work_loop(queue, results, mutex, on_error, &block)
        until queue.empty? || cancellation.cancelled?
          unit = queue.pop(true) rescue nil
          break if unit.nil? || cancellation.cancelled?

          process_safely(unit, results, mutex, on_error, &block)
        end
      end

      def process_safely(unit, results, mutex, on_error, &block)
        res = RailsAdapter.with_connection { unit.process_with(block) }
        mutex.synchronize { results << [unit.index, res] }
        record_progress
      rescue StandardError => e
        mutex.synchronize { on_error.call(e) }
        cancellation.cancel!
      end
    end
  end
end
