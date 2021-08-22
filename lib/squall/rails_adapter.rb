# frozen_string_literal: true

module Squall
  class RailsAdapter
    def self.prepare_for_fork
      return unless defined?(::ActiveRecord::Base)

      ::ActiveRecord::Base.connection_handler.clear_all_connections!
    rescue StandardError
    end

    def self.establish_fork_connection
      return unless defined?(::ActiveRecord::Base)

      ::ActiveRecord::Base.establish_connection
    rescue StandardError
    end

    def self.with_connection(&block)
      if defined?(::ActiveRecord::Base) && ::ActiveRecord::Base.respond_to?(:connection_pool)
        ::ActiveRecord::Base.connection_pool.with_connection(&block)
      else
        yield
      end
    end
  end
end
