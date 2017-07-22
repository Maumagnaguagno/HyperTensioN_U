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
    call('(1.0 + a.to_f).to_s', ['call', '+', '1', '?a'])
    call('(a.to_f + 1.0).to_s', ['call', '+', '?a', '1'])
    call('(a.to_f + b.to_f).to_s', ['call', '+', '?a', '?b'])
  end

  def test_call_sub
    call('-1.0', ['call', '-', '1', '2'])
    call('-1.0', ['call', '-', '1', '2.0'])
    call('-1.0', ['call', '-', '1.0', '2'])
    call('-1.0', ['call', '-', '1.0', '2.0'])
    call('-2.0', ['call', '-', '-1', '1.0'])
    call('2.0', ['call', '-', '1', '-1.0'])
    call('0.0', ['call', '-', '-1', '-1.0'])
    call('(1.0 - a.to_f).to_s', ['call', '-', '1', '?a'])
    call('(a.to_f - 1.0).to_s', ['call', '-', '?a', '1'])
    call('(a.to_f - b.to_f).to_s', ['call', '-', '?a', '?b'])
    # TODO optimize variable minus itself
    call('(a.to_f - a.to_f).to_s', ['call', '-', '?a', '?a'])
  end

  def test_call_mul
    call('6.0', ['call', '*', '3', '2'])
    call('6.0', ['call', '*', '3', '2.0'])
    call('6.0', ['call', '*', '3.0', '2'])
    call('6.0', ['call', '*', '3.0', '2.0'])
    call('-1.0', ['call', '*', '-1', '1.0'])
    call('-1.0', ['call', '*', '1', '-1.0'])
    call('1.0', ['call', '*', '-1', '-1.0'])
    # TODO optimize multiplications by 0 and 1
    call('(1.0 * a.to_f).to_s', ['call', '*', '1', '?a'])
    call('(a.to_f * 1.0).to_s', ['call', '*', '?a', '1'])
    call('(a.to_f * b.to_f).to_s', ['call', '*', '?a', '?b'])
  end

  def test_call_div
    call('1.5', ['call', '/', '3', '2'])
    call('1.5', ['call', '/', '3', '2.0'])
    call('1.5', ['call', '/', '3.0', '2'])
    call('1.5', ['call', '/', '3.0', '2.0'])
    call('-1.0', ['call', '/', '-1', '1.0'])
    call('-1.0', ['call', '/', '1', '-1.0'])
    call('1.0', ['call', '/', '-1', '-1.0'])
    # TODO optimize divisions by 1, raise exception by 0
    call('(1.0 / a.to_f).to_s', ['call', '/', '1', '?a'])
    call('(a.to_f / 1.0).to_s', ['call', '/', '?a', '1'])
    call('(a.to_f / b.to_f).to_s', ['call', '/', '?a', '?b'])
  end

  def test_call_remainder
    call('1.0', ['call', '%', '3', '2'])
    call('1.0', ['call', '%', '3', '2.0'])
    call('1.0', ['call', '%', '3.0', '2'])
    call('1.0', ['call', '%', '3.0', '2.0'])
    call('-0.0', ['call', '%', '-1', '1.0'])
    call('0.0', ['call', '%', '1', '-1.0'])
    call('-0.0', ['call', '%', '-1', '-1.0'])
    call('(1.0 % a.to_f).to_s', ['call', '%', '1', '?a'])
    call('(a.to_f % 1.0).to_s', ['call', '%', '?a', '1'])
    call('(a.to_f % b.to_f).to_s', ['call', '%', '?a', '?b'])
  end

  def test_call_pow
    call('9.0', ['call', '^', '3', '2'])
    call('9.0', ['call', '^', '3', '2.0'])
    call('9.0', ['call', '^', '3.0', '2'])
    call('9.0', ['call', '^', '3.0', '2.0'])
    call('-1.0', ['call', '^', '-1', '1.0'])
    call('1.0', ['call', '^', '1', '-1.0'])
    call('-1.0', ['call', '^', '-1', '-1.0'])
    # TODO optimize pow by 1
    call('(1.0 ** a.to_f).to_s', ['call', '^', '1', '?a'])
    call('(a.to_f ** 1.0).to_s', ['call', '^', '?a', '1'])
    call('(a.to_f ** b.to_f).to_s', ['call', '^', '?a', '?b'])
  end

  def test_call_abs
    call('1.0', ['call', 'abs', '1'])
    call('1.0', ['call', 'abs', '1.0'])
    call('1.0', ['call', 'abs', '-1'])
    call('1.0', ['call', 'abs', '-1.0'])
    call("a.sub(/^-/,'')", ['call', 'abs', '?a'])
  end

  def test_call_sin
    call(Math.sin(0).to_s, ['call', 'sin', '0'])
    call('Math.sin(a.to_f).to_s', ['call', 'sin', '?a'])
    call('Math.sin((a.to_f + b.to_f)).to_s', ['call', 'sin', ['call', '+', '?a', '?b']])
  end

  def test_call_cos
    call(Math.cos(0).to_s, ['call', 'cos', '0'])
    call('Math.cos(a.to_f).to_s', ['call', 'cos', '?a'])
    call('Math.cos((a.to_f + b.to_f)).to_s', ['call', 'cos', ['call', '+', '?a', '?b']])
  end

  def test_call_tan
    call(Math.tan(0).to_s, ['call', 'tan', '0'])
    call('Math.tan(a.to_f).to_s', ['call', 'tan', '?a'])
    call('Math.tan((a.to_f + b.to_f)).to_s', ['call', 'tan', ['call', '+', '?a', '?b']])
  end

  def test_call_equal
    call('true', ['call', '=', '1', '1'])
    call('true', ['call', '=', '?a', '?a'])
    call('false', ['call', '=', '1', '2'])
    call('false', ['call', '=', '2', '1'])
    call('(a.to_f == 1.0)', ['call', '=', '?a', '1'])
    call('(1.0 == a.to_f)', ['call', '=', '1', '?a'])
  end

  def test_call_diff
    call('false', ['call', '!=', '1', '1'])
    call('false', ['call', '!=', '?a', '?a'])
    call('true', ['call', '!=', '1', '2'])
    call('true', ['call', '!=', '2', '1'])
    call('(a.to_f != 1.0)', ['call', '!=', '?a', '1'])
    call('(1.0 != a.to_f)', ['call', '!=', '1', '?a'])
  end

  def test_call_less
    call('false', ['call', '<', '1', '1'])
    call('false', ['call', '<', '?a', '?a'])
    call('true', ['call', '<=', '1', '1'])
    call('true', ['call', '<=', '?a', '?a'])
    call('true', ['call', '<', '1', '2'])
    call('false', ['call', '<', '2', '1'])
    call('true', ['call', '<=', '1', '2'])
    call('false', ['call', '<=', '2', '1'])
    call("(a.to_f < 1.0)", ['call', '<', '?a', '1'])
    call("(1.0 < a.to_f)", ['call', '<', '1', '?a'])
    call("(a.to_f <= 1.0)", ['call', '<=', '?a', '1'])
    call("(1.0 <= a.to_f)", ['call', '<=', '1', '?a'])
  end

  def test_call_greater
    call('false', ['call', '>', '1', '1'])
    call('false', ['call', '>', '?a', '?a'])
    call('true', ['call', '>=', '1', '1'])
    call('true', ['call', '>=', '?a', '?a'])
    call('false', ['call', '>', '1', '2'])
    call('true', ['call', '>', '2', '1'])
    call('false', ['call', '>=', '1', '2'])
    call('true', ['call', '>=', '2', '1'])
    call("(a.to_f > 1.0)", ['call', '>', '?a', '1'])
    call("(1.0 > a.to_f)", ['call', '>', '1', '?a'])
    call("(a.to_f >= 1.0)", ['call', '>=', '?a', '1'])
    call("(1.0 >= a.to_f)", ['call', '>=', '1', '?a'])
  end

  def test_call_member
    call("[1.0, 2.0, 3.0].include?(1.0)", ['call', 'member', '1', ['1', '2', '3']])
    call("[[1.0], [2.0], [3.0]].include?([1.0])", ['call', 'member', ['1'], [['1'], ['2'], ['3']]])
    call("[2.0, 3.0, 4.0, 5.0].include?(4.0)", ['call', 'member', ['call', '*', '2', '2'], ['2', '3', ['call', '+', '1', '3'], '5']])
  end

  def test_nested_calls
    call('6.0', ['call', '+', '3', ['call', '+', '2', '1']])
    call('(a.to_f + (b.to_f + c.to_f)).to_s', ['call', '+', '?a', ['call', '+', '?b', '?c']])
  end

  def test_external_calls
    call("External.test('1.0', a)", ['call', 'test', '1', '?a'])
    call("External.test((1.0 + a.to_f).to_s)", ['call', 'test', ['call', '+', '1', '?a']])
  end
end