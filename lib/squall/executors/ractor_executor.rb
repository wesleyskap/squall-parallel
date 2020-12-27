# frozen_string_literal: true

module Squall
  module Executors
    class RactorExecutor < BaseExecutor
      def execute(producer, &block)
        return ThreadExecutor.new(workers_count: workers_count, cancellation: cancellation).execute(producer, &block) unless ractor_supported?

        units = producer.each_unit.to_a
        return [] if units.empty?

        run_ractors(units, &block)
      end

      private

      def ractor_supported?
        defined?(::Ractor) && ::Ractor.respond_to?(:new)
      end

      def run_ractors(units, &block)
        ThreadExecutor.new(workers_count: workers_count, cancellation: cancellation).execute(
          Producers::ArrayProducer.new(units.map(&:item)),
          &block
        )
      end
    end
  end
end
