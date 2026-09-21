require 'minitest/autorun'

require 'request_store_rails'

require_relative 'test_helper'

class RequestLocalsTest < Minitest::Test

  def test_initial_state
    RequestLocals.set_current_store_id(:random_id)
    assert_empty RequestLocals.store
    assert RequestLocals.current_store_id
  end

  def test_exist_and_delete
    RequestLocals[:foo] = :bar
    assert RequestLocals.store.exist?(:foo)
    RequestLocals.delete(:foo)
    refute RequestLocals.exist?(:foo)
  end

  def test_key_and_delete
    RequestLocals[:foo] = :bar
    assert RequestLocals.store.key?(:foo)
    RequestLocals.delete(:foo)
    refute RequestLocals.key?(:foo)
  end

  def test_clear
    RequestLocals.store[:foo] = :bar
    refute_empty RequestLocals.store
    RequestLocals.clear!
    assert_empty RequestLocals.store
  end

  def test_quacks_like_hash
    RequestLocals[:foo] = :bar
    assert_equal :bar, RequestLocals[:foo]
    assert_equal :bar, RequestLocals.fetch(:foo)
  end

  def test_read
    RequestLocals.store[:foo] = :bar
    assert_equal :bar, RequestLocals[:foo]
    assert_equal :bar, RequestLocals.store[:foo]
  end

  def test_write
    RequestLocals[:foo] = :bar
    assert_equal :bar, RequestLocals.store[:foo]
    RequestLocals.store[:foo] = :boo
    assert_equal :boo, RequestLocals[:foo]
  end

  def test_fetch
    RequestLocals.clear!
    assert_equal 2, RequestLocals.store.fetch(:foo) { 1 + 1 }
    assert_equal 2, RequestLocals.fetch(:foo) { 2 + 2 }
  end

  def test_nested_fetch
    RequestLocals.clear!
    assert_equal 42, RequestLocals.store.fetch(:bar) { 40 + RequestLocals.fetch(:foo) { 2 } }
    assert_equal 2, RequestLocals.store.fetch(:foo) { raise 'not executed' }
    assert_equal 42, RequestLocals.store.fetch(:bar) { raise 'not executed' }
  end

  def test_store_per_request
    RequestLocals.clear_all!
    assert_empty global_store

    RequestLocals.set_current_store_id(:awesome_id)
    RequestLocals[:foo] = :bar

    Thread.new {
      assert_empty RequestLocals.store
      RequestLocals[:foo] = :mar

      RequestLocals.set_current_store_id(:awesome_id)
      assert_equal :bar, RequestLocals.store[:foo]

      RequestLocals.set_current_store_id(:different_id)
      assert_empty RequestLocals.store

      RequestLocals.fetch(:foo) { :beer }
    }.join

    assert_equal :bar, global_store[:awesome_id][:foo]
    assert_equal :beer, global_store[:different_id][:foo]
    assert_equal :mar, global_store[nil][:foo]
  end

  def test_loads_isolated_execution_state
    assert defined?(ActiveSupport::IsolatedExecutionState)
    assert_equal ActiveSupport::IsolatedExecutionState, RequestLocals.context
  end

  def test_keeps_store_id_in_the_legacy_thread_local
    RequestLocals.set_current_store_id(:request_id)

    assert_equal :request_id, Thread.current[RequestLocals::REQUEST_STORE_ID]
  ensure
    RequestLocals.set_current_store_id(nil)
  end

  def test_reads_store_id_from_the_legacy_thread_local
    Thread.current[RequestLocals::REQUEST_STORE_ID] = :legacy_request_id

    assert_equal :legacy_request_id, RequestLocals.current_store_id
  ensure
    RequestLocals.set_current_store_id(nil)
  end

  def test_shares_store_id_with_nested_fibers_when_thread_isolated
    previous_level = ActiveSupport::IsolatedExecutionState.isolation_level
    ActiveSupport::IsolatedExecutionState.isolation_level = :thread
    RequestLocals.set_current_store_id(:parent_request_id)

    nested_id = Fiber.new { RequestLocals.current_store_id }.resume

    assert_equal :parent_request_id, nested_id
  ensure
    RequestLocals.set_current_store_id(nil)
    ActiveSupport::IsolatedExecutionState.isolation_level = previous_level if previous_level
  end

  def test_isolates_store_id_from_nested_fibers_when_fiber_isolated
    previous_level = ActiveSupport::IsolatedExecutionState.isolation_level
    ActiveSupport::IsolatedExecutionState.isolation_level = :fiber
    RequestLocals.set_current_store_id(:parent_request_id)

    nested_id = Fiber.new { RequestLocals.current_store_id }.resume

    assert_nil nested_id
  ensure
    RequestLocals.set_current_store_id(nil)
    ActiveSupport::IsolatedExecutionState.isolation_level = previous_level if previous_level
  end

  def test_clear_per_request
    RequestLocals.clear_all!
    assert_empty global_store

    RequestLocals.set_current_store_id(:awesome_id)
    RequestLocals.fetch(:foo) { :bar }

    Thread.new {
      RequestLocals.set_current_store_id(:awesome_id)
      RequestLocals[:foo] = :beer

      RequestLocals.set_current_store_id(:different_id)
      RequestLocals[:foo] = :mar
      RequestLocals.clear!
    }.join

    global_store = RequestLocals.store.instance_variable_get('@cache')
    assert_equal :beer, global_store[:awesome_id][:foo]
    assert_nil global_store[:different_id]
  end

private

  def global_store
    RequestLocals.store.instance_variable_get('@cache')
  end
end
