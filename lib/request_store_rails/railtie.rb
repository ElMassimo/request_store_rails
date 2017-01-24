module RequestStoreRails

  # Internal: Inserts the middleware to manage request_ids and cleaning up after
  # the request is complete.
  class Railtie < ::Rails::Railtie

    initializer 'request_store_rails.insert_middleware' do |app|
      app.config.middleware.insert_after ActionDispatch::RequestId, RequestStoreRails::Middleware

      clear_all = -> { RequestLocals.clear_all! }

      if defined?(ActiveSupport::Reloader)
        ActiveSupport::Reloader.to_complete(&clear_all)
      else
        ActionDispatch::Reloader.to_cleanup(&clear_all)
      end
    end
  end
end
