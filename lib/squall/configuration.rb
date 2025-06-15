# frozen_string_literal: true

require "etc"

module Squall
  class Configuration
    attr_accessor :default_workers, :default_chunk_size, :reconnect_activerecord, :timeout

    def initialize
      @default_workers = default_processor_count
      @default_chunk_size = 1
      @reconnect_activerecord = true
      @timeout = nil
    end

    private

    def default_processor_count
      Etc.respond_to?(:nprocessors) ? Etc.nprocessors : 4
    rescue StandardError
      4
    end
  end
end
