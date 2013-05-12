module Squall
  module Producers
    class LazyProducer
      def initialize(enum)
        @enum = enum
      end

      def each_unit
        return enum_for(:each_unit) unless block_given?

        idx = 0
        @enum.each do |item|
          yield WorkUnit.new(item, idx)
          idx += 1
        end
      end

      def size
        @enum.respond_to?(:size) ? @enum.size : nil
      end
    end
  end
end
