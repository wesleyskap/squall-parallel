require_relative "squall/version"
require_relative "squall/errors"
require_relative "squall/work_unit"
require_relative "squall/rails_adapter"
require_relative "squall/producers/array_producer"
require_relative "squall/producers/range_producer"
require_relative "squall/executors/base_executor"
require_relative "squall/executors/thread_executor"
require_relative "squall/executors/process_executor"

module Squall
  def self.map(collection, options = {}, &block)
    producer = collection.is_a?(Range) ? Producers::RangeProducer.new(collection) : Producers::ArrayProducer.new(collection)
    executor = options[:in_processes] ? Executors::ProcessExecutor.new(options[:in_processes]) : Executors::ThreadExecutor.new(options[:in_threads] || 4)
    executor.execute(producer, &block)
  end

  def self.each(collection, options = {}, &block)
    map(collection, options, &block)
    collection
  end
end
