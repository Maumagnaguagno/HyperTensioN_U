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
  end

  def test_call_div
    call('1.5', ['call', '/', '3', '2'])
    call('1.5', ['call', '/', '3', '2.0'])
    call('1.5', ['call', '/', '3.0', '2'])
    call('1.5', ['call', '/', '3.0', '2.0'])
    call('-1.0', ['call', '/', '-1', '1.0'])
    call('-1.0', ['call', '/', '1', '-1.0'])
    call('1.0', ['call', '/', '-1', '-1.0'])
  end

  def test_call_remainder
    call('1.0', ['call', '%', '3', '2'])
    call('1.0', ['call', '%', '3', '2.0'])
    call('1.0', ['call', '%', '3.0', '2'])
    call('1.0', ['call', '%', '3.0', '2.0'])
    call('-0.0', ['call', '%', '-1', '1.0'])
    call('0.0', ['call', '%', '1', '-1.0'])
    call('-0.0', ['call', '%', '-1', '-1.0'])
  end

  def test_call_exp
    call('9.0', ['call', '**', '3', '2'])
    call('9.0', ['call', '**', '3', '2.0'])
    call('9.0', ['call', '**', '3.0', '2'])
    call('9.0', ['call', '**', '3.0', '2.0'])
    call('-1.0', ['call', '**', '-1', '1.0'])
    call('1.0', ['call', '**', '1', '-1.0'])
    call('-1.0', ['call', '**', '-1', '-1.0'])
  end

  def test_abs_negative
    call('1.0', ['call', 'abs', '1'])
    call('1.0', ['call', 'abs', '1.0'])
    call('1.0', ['call', 'abs', '-1'])
    call('1.0', ['call', 'abs', '-1.0'])
  end

  def test_call_sin
    # TODO
  end

  def test_call_cos
    # TODO
  end

  def test_call_tan
    # TODO
  end

  def test_call_equal
    # TODO
    #call('true', ['call', '=', '1', '1'])
    #call('true', ['call', '=', '?a', '?a'])
    #call('false', ['call', '=', '1', '2'])
    #call('false', ['call', '=', '2', '1'])
  end

  def test_call_diff
    # TODO
    #call('false', ['call', '!=', '1', '1'])
    #call('false', ['call', '!=', '?a', '?a'])
    #call('true', ['call', '!=', '1', '2'])
    #call('true', ['call', '!=', '2', '1'])
  end

  def test_call_compare
    # TODO
    #call('0', ['call', '=', '1', '1'])
    #call('0', ['call', '=', '?a', '?a'])
    #call('-1', ['call', '=', '1', '2'])
    #call('1', ['call', '=', '2', '1'])
  end
end