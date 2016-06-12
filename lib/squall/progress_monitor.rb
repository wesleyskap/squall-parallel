# frozen_string_literal: true

module Squall
  class ProgressMonitor
    attr_reader :total, :processed

    def initialize(total = nil)
      @total = total
      @processed = 0
      @start_time = Time.now
      @mutex = Mutex.new
    end

    def increment
      @mutex.synchronize { @processed += 1 }
    end

    def percent_complete
      return 0.0 unless total && total.positive?

      ((processed.to_f / total) * 100).round(2)
    end

    def eta_seconds
      return nil unless total && total.positive? && processed.positive?

      elapsed = Time.now - @start_time
      rate = processed.to_f / elapsed
      remaining = total - processed
      (remaining / rate).round(1)
    end
  end
end
