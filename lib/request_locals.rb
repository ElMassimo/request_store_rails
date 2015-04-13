require 'singleton'
require 'forwardable'
require 'thread_safe'

# Public: Provides per-request global storage, by offering an interface that is
# very similar to Rails.cache, or Hash.
#
# The store may be shared between threads, as long as the :request_id
# thread-local variable is set.
#
# Intended to work in collaboration with the RequestStoreRails middleware, that
# will clear the request local variables after each request.
class RequestLocals
  include Singleton
  extend Forwardable

  class << self
    extend Forwardable

    # Public: Public methods of RequestLocals, they are delegated to the Singleton instance.
    def_delegators :instance, :clear!, :clear_all!, :[], :[]=, :fetch, :delete, :exist?, :empty?

    # Public: There is no accounting for taste, RequestLocals[:foo] vs RequestLocals.store[:foo]
    alias_method :store, :instance

    # Internal: We don't want to expose the Singleton implementation details.
    private :instance
  end

  # Internal: Methods of the RequestLocals instance, delegated to the request-local structure.
  def_delegators :store, :[], :[]=, :delete, :empty?

  def initialize
    @cache = ThreadSafe::Cache.new
  end

  # Public: Removes all the request-local variables.
  #
  # Returns nothing.
  def clear!
    @cache.delete(current_request_id)
  end

  # Public: Clears all the request-local variable stores.
  #
  # Returns nothing.
  def clear_all!
    @cache = ThreadSafe::Cache.new
  end

  # Public: Checks if a value was stored for the given key.
  #
  # Returns true if there is a value stored for the key.
  def exist?(key)
    store.key?(key)
  end

  # Public: Implements fetch in a consistent way with Rails.cache, persisting
  # the value yielded by the block if the key was not found.
  #
  # Returns an existing value for the key is found, otherwise it returns the
  # value yielded by the block.
  def fetch(key, &block)
    store.compute_if_absent(key, &block)
  end

protected

  # Internal: Returns the structure that holds the request-local variables for
  # the current request.
  #
  # Returns a ThreadSafe::Cache.
  def store
    @cache.compute_if_absent(current_request_id) { new_store }
  end

  # Internal: The current request is inferred from the current thread. It's very
  # important to pass on the :request_id thread local variable when spawning new
  # threads within a single request.
  def current_request_id
    Thread.current[:request_id]
  end

  # Internal: Returns a new empty structure where the request-local variables
  # will be stored.
  def new_store
    ThreadSafe::Cache.new
  end
end
