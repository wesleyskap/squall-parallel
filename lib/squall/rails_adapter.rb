module Squall
  class RailsAdapter
    def self.establish_fork_connection
      if defined?(::ActiveRecord::Base)
        ::ActiveRecord::Base.establish_connection
      end
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
