require 'securerandom'

module RequestStoreRails

  # Public: Middleware that takes care of setting the thread-local variable
  # :request_id, which enables RequestLocals to associate threads and requests.
  class Middleware

    def initialize(app)
      @app = app
    end

    # Internal: Assigns the :request_id thread-local variable, and cleans up all
    # the request-local variables after the request.
    def call(env)
      Thread.current[:request_id] = extract_request_id(env)
      @app.call(env)
    ensure
      RequestLocals.clear!
      Thread.current[:request_id] = nil
    end

  protected

    # Internal: Extracts the request id from the environment, or generates one.
    def extract_request_id(env)
      env['action_dispatch.request_id'] || env['HTTP_X_REQUEST_ID'] || SecureRandom.hex(16)
    end
  end
end
