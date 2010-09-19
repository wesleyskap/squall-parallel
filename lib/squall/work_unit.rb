module Squall
  class WorkUnit
    attr_reader :item, :index

    def initialize(item, index)
      @item = item
      @index = index
    end

    def process_with(block)
      block.call(item)
    end
  end
end
