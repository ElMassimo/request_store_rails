require 'minitest/autorun'

require 'request_store_rails'

class MiddlewareTest < Minitest::Unit::TestCase
  def setup
    @app = RackApp.new
    @middleware = RequestStoreRails::Middleware.new(@app)

    Thread.current[:request_id] = nil
    RequestLocals.clear_all!
  end

  def test_middleware_resets_store
    2.times { @middleware.call({}) }

    assert_equal 1, @app.last_value
    assert_empty RequestLocals.store
  end

  def test_middleware_resets_store_on_error
    errors = []
    begin
      @middleware.call({ error: true })
    rescue => e
      errors << e
    end
    assert_equal ['FAIL'], errors.map(&:message)
    assert_empty RequestLocals.store
  end
end
