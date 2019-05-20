require 'singleton'
require 'forwardable'
require 'concurrent'

# Public: Provides per-request global storage, by offering an interface that is
# very similar to Rails.cache, or Hash.
#
# The store may be shared between threads, as long as the current store id is
# set as a thread-local variable.
#
# Intended to work in collaboration with the RequestStoreRails middleware, that
# will clear the request local variables after each request.
class RequestLocals
  include Singleton
  extend Forwardable

  # Internal: The key of the thread-local variable the library uses to store the
  # identifier of the current store, used during the request lifecycle.
  REQUEST_STORE_ID = :request_store_id

  class << self
    extend Forwardable

    # Public: Public methods of RequestLocals, they are delegated to the Singleton instance.
    def_delegators :instance, :clear!, :clear_all!, :current_store_id, :[], :[]=, :fetch, :delete, :exist?, :key?, :empty?

    # Public: There is no accounting for taste, RequestLocals[:foo] vs RequestLocals.store[:foo]
    alias_method :store, :instance

    # Internal: We don't want to expose the Singleton implementation details.
    private :instance
  end

  # Internal: Cache that supports nested access by using a monitor instead of a mutex.
  class Cache < Concurrent::Map
    def initialize(options = nil)
      super(options)
      @write_lock = Monitor.new
    end
  end

  # Internal: Methods of the RequestLocals instance, delegated to the request-local structure.
  def_delegators :store, :[], :[]=, :delete, :empty?

  def initialize
    @cache = Cache.new
  end

  # Public: Removes all the request-local variables.
  #
  # Returns nothing.
  def clear!
    @cache.delete(current_store_id)
  end

  # Public: Clears all the request-local variable stores.
  #
  # Returns nothing.
  def clear_all!
    @cache = Cache.new
  end

  # Public: Checks if a value was stored for the given key.
  #
  # Returns true if there is a value stored for the key.
  def exist?(key)
    store.key?(key)
  end

  # Public: Alias to exist?
  alias_method :key?, :exist?

  # Public: Implements fetch in a consistent way with Rails.cache, persisting
  # the value yielded by the block if the key was not found.
  #
  # Returns an existing value for the key is found, otherwise it returns the
  # value yielded by the block.
  def fetch(key, &block)
    store.compute_if_absent(key, &block)
  end

  # Public: The current request is inferred from the current thread.
  #
  # NOTE: It's very important to set the current store id when spawning new
  # threads within a single request, using `RequestLocals.set_current_store_id`.
  def current_store_id
    Thread.current[REQUEST_STORE_ID]
  end

  # Public: Changes the store RequestLocals will read from in the current thread.
  def self.set_current_store_id(id)
    Thread.current[REQUEST_STORE_ID] = id
  end

protected

  # Internal: Returns the structure that holds the request-local variables for
  # the current request.
  #
  # Returns a ThreadSafe::Cache.
  def store
    @cache.compute_if_absent(current_store_id) { new_store }
  end

  # Internal: Returns a new empty structure where the request-local variables
  # will be stored.
  def new_store
    Cache.new
  end
end
