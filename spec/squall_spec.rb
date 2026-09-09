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

  describe "process execution" do
    it "supports process executor mode" do
      input = [10, 20, 30]
      results = Squall.map(input, in_processes: 2) { |n| n / 10 }
      expect(results).to eq([1, 2, 3])
    end
  end

  describe ".flat_map" do
    it "flattens results by one level" do
      results = Squall.flat_map([1, 2], in_threads: 2) { |n| [n, n * 10] }
      expect(results).to eq([1, 10, 2, 20])
    end
  end

  describe ".any? and .all?" do
    it "stops early with any?" do
      input = [1, 3, 5, 8, 9]
      found = Squall.any?(input, in_threads: 2) { |n| n.even? }
      expect(found).to be true
    end

    it "validates all items with all?" do
      input = [2, 4, 6, 8]
      expect(Squall.all?(input, in_threads: 2) { |n| n.even? }).to be true
      expect(Squall.all?([2, 3, 4], in_threads: 2) { |n| n.even? }).to be false
    end

    it "cancels processing and does not evaluate subsequent elements" do
      evaluated = []
      mutex = Mutex.new
      Squall.any?(1..100, in_threads: 1) do |n|
        mutex.synchronize { evaluated << n }
        n == 2
      end
      expect(evaluated.size).to be < 10
    end
  end

  describe "error handling (fail-fast)" do
    it "immediately raises exception and cancels workers on error" do
      expect do
        Squall.map(1..20, in_threads: 2) do |n|
          raise "Worker failure on #{n}" if n == 5

          n * 2
        end
      end.to raise_error(StandardError, /Worker failure on 5/)
    end
  end
end
