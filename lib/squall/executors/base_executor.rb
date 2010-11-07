module Squall
  module Executors
    class BaseExecutor
      attr_reader :workers_count

      def initialize(workers_count = 4)
        @workers_count = workers_count
      end

      def execute(producer, &block)
        raise NotImplementedError, "#{self.class} must implement #execute"
      end
    end
  end
end
