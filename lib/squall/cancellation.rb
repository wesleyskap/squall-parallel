# frozen_string_literal: true

module Squall
  # Thread-safe cancellation token with listener notification.
  # Example:
  #   token = Squall::Cancellation.new
  #   token.on_cancel { puts "cancelled" }
  #   token.cancel!
  class Cancellation
    def initialize
      @cancelled = false
      @callbacks = []
      @mutex = Mutex.new
    end

    def cancel!
      listeners = @mutex.synchronize do
        return [] if @cancelled

        @cancelled = true
        @callbacks.dup
      end
      listeners.each(&:call)
      true
    end

    def cancelled?
      @mutex.synchronize { @cancelled }
    end

    def on_cancel(&block)
      already_cancelled = @mutex.synchronize do
        @callbacks << block unless @cancelled
        @cancelled
      end
      block.call if already_cancelled
    end

    def check!
      return unless cancelled?

      raise CancelledError, "Execution was aborted: cancellation token was triggered."
    end
  end
end
