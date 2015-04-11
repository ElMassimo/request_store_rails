# Internal: Inserts the middleware to manage request_ids and cleaning up after
# the request is complete.
module RequestStoreRails
  class Railtie < ::Rails::Railtie

    initializer 'request_store_rails.insert_middleware' do |app|
      app.config.middleware.insert_after ActionDispatch::RequestId, RequestStoreRails::Middleware

      ActionDispatch::Reloader.to_cleanup do
        RequestLocals.clear_all!
      end
    end
  end
end
