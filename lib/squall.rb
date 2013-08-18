require_relative "squall/version"
require_relative "squall/errors"
require_relative "squall/work_unit"
require_relative "squall/rails_adapter"
require_relative "squall/producers/array_producer"
require_relative "squall/producers/range_producer"
require_relative "squall/producers/queue_producer"
require_relative "squall/producers/lazy_producer"
require_relative "squall/executors/base_executor"
require_relative "squall/executors/thread_executor"
require_relative "squall/executors/process_executor"

module Squall
  def self.map(collection, options = {}, &block)
    producer = wrap_producer(collection)
    executor = build_executor(options)
    executor.execute(producer, &block)
  end

  def self.each(collection, options = {}, &block)
    map(collection, options, &block)
    collection
  end

  def self.each_with_index(collection, options = {}, &block)
    producer = wrap_producer(collection)
    executor = build_executor(options)
    executor.execute(producer) { |item| block.call(item, producer.to_a.index(item)) }
  end

  def self.flat_map(collection, options = {}, &block)
    map(collection, options, &block).flatten(1)
  end

  private

  def self.wrap_producer(collection)
    if collection.is_a?(Range)
      Producers::RangeProducer.new(collection)
    elsif defined?(::Queue) && collection.is_a?(::Queue)
      Producers::QueueProducer.new(collection)
    elsif collection.respond_to?(:lazy) && collection.is_a?(Enumerator::Lazy)
      Producers::LazyProducer.new(collection)
    else
      Producers::ArrayProducer.new(collection)
    end
  end

  def self.build_executor(options)
    if options[:in_processes]
      Executors::ProcessExecutor.new(options[:in_processes])
    else
      Executors::ThreadExecutor.new(options[:in_threads] || 4)
    end
  end
end
