module Squall
  module Producers
    class QueueProducer
      def initialize(queue)
        @queue = queue
      end

      def each_unit
        return enum_for(:each_unit) unless block_given?

        idx = 0
        until @queue.empty?
          item = @queue.pop(true) rescue nil
          break if item.nil?

          yield WorkUnit.new(item, idx)
          idx += 1
        end
      end

      def size
        @queue.size
      end
    end
  end
end
