require "spec_helper"

RSpec.describe Squall do
  describe ".map" do
    it "maps array items concurrently using threads" do
      input = [1, 2, 3, 4, 5]
      results = Squall.map(input, in_threads: 2) { |n| n * 2 }
      expect(results).to eq([2, 4, 6, 8, 10])
    end

    it "maps range inputs correctly" do
      results = Squall.map(1..5, in_threads: 2) { |n| n + 1 }
      expect(results).to eq([2, 3, 4, 5, 6])
    end
  end
end
