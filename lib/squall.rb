# frozen_string_literal: true

require_relative "squall/version"
require_relative "squall/errors"
require_relative "squall/configuration"
require_relative "squall/work_unit"
require_relative "squall/cancellation"
require_relative "squall/progress_monitor"
require_relative "squall/rails_adapter"
require_relative "squall/producers/array_producer"
require_relative "squall/producers/range_producer"
require_relative "squall/producers/queue_producer"
require_relative "squall/producers/lazy_producer"
require_relative "squall/executors/base_executor"
require_relative "squall/executors/thread_executor"
require_relative "squall/executors/process_executor"
require_relative "squall/executors/ractor_executor"

module Squall
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    # Maps collection concurrently across workers.
    # Example:
    #   Squall.map([1, 2, 3], in_threads: 2) { |n| n * 2 }
    def map(collection, options = {}, &block)
      producer = wrap_producer(collection)
      executor = build_executor(options, producer.size)
      executor.execute(producer, &block)
    end

    # Iterates collection concurrently and returns the original collection.
    # Example:
    #   Squall.each(urls, in_threads: 4) { |url| ping(url) }
    def each(collection, options = {}, &block)
      map(collection, options, &block)
      collection
    end

    # Iterates collection concurrently providing item and original index.
    # Example:
    #   Squall.each_with_index(records, in_threads: 2) { |rec, idx| save(rec, idx) }
    def each_with_index(collection, options = {}, &block)
      producer = wrap_producer(collection)
      executor = build_executor(options, producer.size)
      executor.execute(producer) { |item| block.call(item, producer.to_a.index(item)) }
    end

    # Maps collection concurrently and flattens result by one dimension.
    # Example:
    #   Squall.flat_map([1, 2], in_threads: 2) { |n| [n, n * 10] }
    def flat_map(collection, options = {}, &block)
      map(collection, options, &block).flatten(1)
    end

    # Evaluates truthiness concurrently, cancelling on first truthy match.
    # Example:
    #   Squall.any?(users, in_threads: 4) { |u| u.admin? }
    def any?(collection, options = {}, &block)
      cancellation = Cancellation.new
      opts = options.merge(cancellation: cancellation)
      found = false

      map(collection, opts) do |item|
        if block.call(item)
          found = true
          cancellation.cancel!
        end
      end
      found
    end

    # Evaluates whether all items match condition, cancelling on first falsy.
    # Example:
    #   Squall.all?(numbers, in_threads: 4) { |n| n.positive? }
    def all?(collection, options = {}, &block)
      cancellation = Cancellation.new
      opts = options.merge(cancellation: cancellation)
      all_match = true

      map(collection, opts) do |item|
        unless block.call(item)
          all_match = false
          cancellation.cancel!
        end
      end
      all_match
    end

    private

    def wrap_producer(collection)
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

    def build_executor(options, total_size)
      workers = options[:in_threads] || options[:in_processes] || options[:in_ractors] || configuration.default_workers
      monitor = options[:progress] ? ProgressMonitor.new(total_size) : nil
      cancel = options[:cancellation] || Cancellation.new

      if options[:in_processes]
        Executors::ProcessExecutor.new(workers_count: workers, progress_monitor: monitor, cancellation: cancel)
      elsif options[:in_ractors]
        Executors::RactorExecutor.new(workers_count: workers, progress_monitor: monitor, cancellation: cancel)
      else
        Executors::ThreadExecutor.new(workers_count: workers, progress_monitor: monitor, cancellation: cancel)
      end
    end
  end
end
