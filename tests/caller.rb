require 'test/unit'
require './UHyper_Compiler'

class Caller < Test::Unit::TestCase

  def call(expected, formula)
    assert_equal(expected, UHyper_Compiler.call(formula))
  end

  def test_call_add
    call('3.0', ['call', '+', '1', '2'])
    call('3.0', ['call', '+', '1', '2.0'])
    call('3.0', ['call', '+', '1.0', '2'])
    call('3.0', ['call', '+', '1.0', '2.0'])
    call('0.0', ['call', '+', '-1', '1.0'])
    call('0.0', ['call', '+', '1', '-1.0'])
    call('-2.0', ['call', '+', '-1', '-1.0'])
  end

  def test_call_sub
    call('-1.0', ['call', '-', '1', '2'])
    call('-1.0', ['call', '-', '1', '2.0'])
    call('-1.0', ['call', '-', '1.0', '2'])
    call('-1.0', ['call', '-', '1.0', '2.0'])
    call('-2.0', ['call', '-', '-1', '1.0'])
    call('2.0', ['call', '-', '1', '-1.0'])
    call('0.0', ['call', '-', '-1', '-1.0'])
  end

  def test_call_mul
    call('6.0', ['call', '*', '3', '2'])
    call('6.0', ['call', '*', '3', '2.0'])
    call('6.0', ['call', '*', '3.0', '2'])
    call('6.0', ['call', '*', '3.0', '2.0'])
    call('-1.0', ['call', '*', '-1', '1.0'])
    call('-1.0', ['call', '*', '1', '-1.0'])
    call('1.0', ['call', '*', '-1', '-1.0'])
    call('1.0', ['call', '*', '-1', '-1.0'])
  end
end