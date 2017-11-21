require 'test/unit'
require './Hypertension_U'

class Sphygmomanometer < Test::Unit::TestCase

  def simple_state
    {
      'a' => [['1'], ['2'], ['3']],
      'b' => [['3'], ['4'], ['5']],
      'c' => [['a','b'], ['c','d']],
      'd' => [['d','x']]
    }
  end

  def test_attributes
    [:domain, :domain=, :state, :state=, :min_prob, :min_prob=, :max_plans, :max_plans=, :plans, :plans=, :debug, :debug=].each {|att| assert_respond_to(Hypertension_U, att)}
  end

  #-----------------------------------------------
  # Planning
  #-----------------------------------------------

  def test_planning_empty
    Hypertension_U.state = original_state = simple_state
    Hypertension_U.domain = {}
    Hypertension_U.plans = []
    Hypertension_U.max_plans = -1
    Hypertension_U.min_prob = 0
    Hypertension_U.planning([])
    assert_equal([[1, 0]], Hypertension_U.plans)
    # No state was created
    assert_same(original_state, Hypertension_U.state)
  end

  def test_planning_success
    # TODO
  end

  def test_planning_failure
    # TODO
  end

  def test_planning_exception
    Hypertension_U.state = simple_state
    Hypertension_U.domain = {}
    Hypertension_U.plans = []
    Hypertension_U.max_plans = -1
    Hypertension_U.min_prob = 0
    e = assert_raises(RuntimeError) {Hypertension_U.planning([['exception_rise']])}
    assert_equal('Domain defines no decomposition for exception_rise', e.message)
  end

  #-----------------------------------------------
  # Execute
  #-----------------------------------------------

  def test_execute_probability_failure
    # TODO
  end

  def test_execute_send_failure
    # TODO
  end

  def test_execute_success
    # TODO
  end

  #-----------------------------------------------
  # Generate
  #-----------------------------------------------

  def test_generate
    expected = ['1','2','3'].product(['4','5'], ['c'], ['d'])
    Hypertension_U.state = simple_state
    # Free variables
    x = ''
    y = ''
    w = ''
    z = ''
    # Generate x y w z based on state and preconditions
    Hypertension_U.generate(
      [
        ['a', x],
        ['b', y],
        ['c', w, z],
        ['d', z, 'x']
      ],
      [
        ['a', y]
      ], x, y, w, z
    ) {
      assert_equal(expected.shift, [x,y,w,z])
    }
    assert_equal(true, expected.empty?)
  end

  #-----------------------------------------------
  # Applicable?
  #-----------------------------------------------

  def test_applicable_empty
    Hypertension_U.state = original_state = simple_state
    assert_equal(true, Hypertension_U.applicable?([],[]))
    # No state was created
    assert_same(original_state, Hypertension_U.state)
  end

  def test_applicable_success
    Hypertension_U.state = original_state = simple_state
    assert_equal(true, Hypertension_U.applicable?([['a','1']],[['a','x']]))
    # No state was created
    assert_same(original_state, Hypertension_U.state)
  end

  def test_applicable_failure
    Hypertension_U.state = original_state = simple_state
    assert_equal(false, Hypertension_U.applicable?([['a','1']],[['a','2']]))
    # No state was created
    assert_same(original_state, Hypertension_U.state)
  end

  #-----------------------------------------------
  # Apply
  #-----------------------------------------------

  def test_apply_empty_effects
    Hypertension_U.state = original_state = simple_state
    # Successfully applied
    assert_equal(true, Hypertension_U.apply([],[]))
    # New state was created
    assert_not_same(original_state, Hypertension_U.state)
    # Same content
    assert_equal(original_state, Hypertension_U.state)
  end

  def test_apply_success
    Hypertension_U.state = original_state = simple_state
    # Successfully applied
    assert_equal(true, Hypertension_U.apply([['a','y']],[['a','y']]))
    # New state was created
    assert_not_same(original_state, Hypertension_U.state)
    # Delete effects must happen before addition, otherwise the effect nullifies itself
    expected = simple_state
    expected['a'] << ['y']
    assert_equal(expected, Hypertension_U.state)
  end

  #-----------------------------------------------
  # Apply operator
  #-----------------------------------------------

  def test_apply_operator_empty_effects
    Hypertension_U.state = original_state = simple_state
    # Successfully applied
    assert_equal(true, Hypertension_U.apply_operator([['a','1']],[['a','x']],[],[]))
    # New state was created
    assert_not_same(original_state, Hypertension_U.state)
    # Same content
    assert_equal(original_state, Hypertension_U.state)
  end

  def test_apply_operator_success
    Hypertension_U.state = original_state = simple_state
    # Successfully applied
    assert_equal(true, Hypertension_U.apply_operator([['a','1']],[['a','x']],[['a','y']],[['a','y']]))
    # New state was created
    assert_not_same(original_state, Hypertension_U.state)
    # Delete effects must happen before addition, otherwise the effect nullifies itself
    expected = simple_state
    expected['a'] << ['y']
    assert_equal(expected, Hypertension_U.state)
  end

  def test_apply_operator_failure
    Hypertension_U.state = original_state = simple_state
    # Precondition failure
    assert_nil(Hypertension_U.apply_operator([],[['a','2']],[['a','y']],[]))
    # No state was created
    assert_same(original_state, Hypertension_U.state)
  end
end