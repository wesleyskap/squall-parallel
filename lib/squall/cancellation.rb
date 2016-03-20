# frozen_string_literal: true

module Squall
  class Cancellation
    def initialize
      @cancelled = false
      @mutex = Mutex.new
    end

    def cancel!
      @mutex.synchronize { @cancelled = true }
    end

    def cancelled?
      @mutex.synchronize { @cancelled }
    end

    def check!
      raise CancelledError, "Execution was aborted by cancellation" if cancelled?
    end
  end
end
