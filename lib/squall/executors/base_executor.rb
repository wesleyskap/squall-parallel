# frozen_string_literal: true

module Squall
  module Executors
    class BaseExecutor
      attr_reader :workers_count, :progress_monitor, :cancellation

      def initialize(workers_count: 4, progress_monitor: nil, cancellation: nil)
        @workers_count = workers_count
        @progress_monitor = progress_monitor
        @cancellation = cancellation || Cancellation.new
      end

      def execute(producer, &block)
        raise NotImplementedError, "#{self.class} must implement #execute"
      end

      protected

      def record_progress
        @progress_monitor&.increment
      end

      def check_cancellation!
        @cancellation.check!
      end
    end
  end
end
