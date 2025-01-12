# frozen_string_literal: true

module Squall
  module Producers
    class ArrayProducer
      def initialize(collection)
        @collection = collection.to_a
      end

      def each_unit
        return enum_for(:each_unit) unless block_given?

        @collection.each_with_index do |item, idx|
          yield WorkUnit.new(item, idx)
        end
      end

      def size
        @collection.size
      end
    end
  end
end
