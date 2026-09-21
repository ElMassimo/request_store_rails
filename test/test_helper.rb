require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

require 'pry'

require 'minitest/reporters'
Minitest::Reporters.use!

class RackApp
  attr_reader :last_value

  def call(env)
    RequestLocals.store[:foo] ||= 0
    RequestLocals.store[:foo] += 1
    @last_value = RequestLocals.store[:foo]
    raise 'FAIL' if env[:error]
  end
end
