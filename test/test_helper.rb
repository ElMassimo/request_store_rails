require 'pry'

require 'minitest/reporters'
Minitest::Reporters.use!

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

class RackApp
  attr_reader :last_value

  def call(env)
    RequestLocals.store[:foo] ||= 0
    RequestLocals.store[:foo] += 1
    @last_value = RequestLocals.store[:foo]
    raise 'FAIL' if env[:error]
  end
end
