require 'securerandom'

module RequestStoreRails

  # Public: Middleware that takes care of setting a thread-local variable, which
  # enables RequestLocals to associate threads with the store for a request.
  class Middleware

    def initialize(app)
      @app = app
    end

    # Internal: Assigns a thread-local variable to identify the current store,
    # and cleans up all the variables stored for the request once it finishes.
    def call(env)
      RequestLocals.set_current_store_id(extract_request_id(env))
      @app.call(env)
    ensure
      RequestLocals.clear!
      RequestLocals.set_current_store_id(nil)
    end

  protected

    # Internal: Extracts the request id from the environment, or generates one.
    #
    # NOTE: We always generate an id to prevent accidental conflicts from an
    # externally provided one, but subclasses of this middleware might override
    # it.
    def extract_request_id(env)
      SecureRandom.uuid
    end
  end
end
