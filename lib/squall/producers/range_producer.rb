module Squall
  module Producers
    class RangeProducer
      def initialize(range)
        @range = range
      end

      def each_unit
        return enum_for(:each_unit) unless block_given?

        idx = 0
        @range.each do |item|
          yield WorkUnit.new(item, idx)
          idx += 1
        end
      end

      def size
        @range.size
      end
    end
  end
end
