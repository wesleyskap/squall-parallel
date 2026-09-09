# frozen_string_literal: true

module Squall
  module Executors
    # Share-nothing Ractor parallelism with graceful Thread fallback.
    # Example:
    #   executor = Squall::Executors::RactorExecutor.new(workers_count: 4)
    #   results = executor.execute(producer) { |item| item * 2 }
    class RactorExecutor < BaseExecutor
      def execute(producer, &block)
        return fallback_to_threads(producer, &block) unless ractor_supported?

        units = producer.each_unit.to_a
        return [] if units.empty?

        run_ractors_safely(units, producer, &block)
      end

      private

      def ractor_supported?
        defined?(::Ractor) && ::Ractor.respond_to?(:new)
      end

      def fallback_to_threads(producer, &block)
        ThreadExecutor.new(
          workers_count: workers_count,
          progress_monitor: progress_monitor,
          cancellation: cancellation
        ).execute(producer, &block)
      end

      def run_ractors_safely(units, producer, &block)
        execute_native_ractors(units, &block)
      rescue StandardError => e
        # If block closes over outer non-shareable scope or raises isolation error, fallback
        fallback_to_threads(producer, &block)
      end

      def execute_native_ractors(units, &block)
        workers = spawn_ractor_workers(workers_count, &block)
        dispatch_units_and_collect(units, workers)
      end

      def spawn_ractor_workers(count, &block)
        Array.new(count) do
          Ractor.new(block) do |worker_block|
            loop do
              unit = Ractor.receive
              break if unit == :stop

              Ractor.yield([unit.index, worker_block.call(unit.item)])
            end
          end
        end
      end

      def dispatch_units_and_collect(units, workers)
        units.each_with_index do |unit, i|
          workers[i % workers.size].send(unit)
        end
        collected = units.map do
          ractor, (idx, res) = Ractor.select(*workers)
          record_progress
          [idx, res]
        end
        workers.each { |w| w.send(:stop) rescue nil }
        collected.sort_by { |idx, _| idx }.map { |_, val| val }
      end
    end
  end
end
