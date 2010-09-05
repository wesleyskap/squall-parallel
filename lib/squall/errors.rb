module Squall
  class Error < StandardError; end
  class ExecutionError < Error; end
  class TimeoutError < Error; end
  class CancelledError < Error; end
  class WorkerCrashError < Error; end
end
