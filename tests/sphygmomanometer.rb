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

  def setup_planner(state, max_plans = -1, min_prob = 0)
    Hypertension_U.state = state
    Hypertension_U.domain = {:operator => 1}
    Hypertension_U.plans = []
    Hypertension_U.max_plans = max_plans
    Hypertension_U.min_prob = min_prob
  end

  def Hypertension_U.operator(param)
    param
  end

  def test_attributes
    [:domain, :domain=, :state, :state=, :min_prob, :min_prob=, :max_plans, :max_plans=, :plans, :plans=, :debug, :debug=].each {|att| assert_respond_to(Hypertension_U, att)}
  end

  #-----------------------------------------------
  # Planning
  #-----------------------------------------------

  def test_planning_empty
    setup_planner(original_state = simple_state)
    Hypertension_U.planning([])
    assert_equal([[1, 0]], Hypertension_U.plans)
    # No state was created
    assert_same(original_state, Hypertension_U.state)
  end

  def test_planning_success
    setup_planner(original_state = simple_state)
    Hypertension_U.planning([[:operator, true]])
    assert_equal([[1, 0, [:operator, true]]], Hypertension_U.plans)
    # No state was created
    assert_same(original_state, Hypertension_U.state)
  end

  def test_planning_failure
    setup_planner(original_state = simple_state)
    Hypertension_U.planning([[:operator, false]])
    assert_equal([], Hypertension_U.plans)
    # Keep original state
    assert_same(original_state, Hypertension_U.state)
  end

  def test_planning_exception
    setup_planner(original_state = simple_state)
    e = assert_raises(RuntimeError) {Hypertension_U.planning([['exception_rise']])}
    assert_equal('Domain defines no decomposition for exception_rise', e.message)
  end

  #-----------------------------------------------
  # Execute
  #-----------------------------------------------

  def test_execute_probability_failure
    setup_planner(original_state = simple_state, -1, 0.5)
    Hypertension_U.execute([:operator, true], 0, [], 0, [1,0])
    assert_equal([], Hypertension_U.plans)
    # No state was created
    assert_same(original_state, Hypertension_U.state)
  end

  def test_execute_send_failure
    setup_planner(original_state = simple_state)
    Hypertension_U.execute([:operator, false], 0, [], 0, [1,0])
    assert_equal([], Hypertension_U.plans)
    # No state was created
    assert_same(original_state, Hypertension_U.state)
  end

  def test_execute_success
    setup_planner(original_state = simple_state)
    Hypertension_U.execute([:operator, true], 0.4, [], 0, [0.4,0])
    assert_equal([[0.4 * 0.4, 0, [:operator, true]]], Hypertension_U.plans)
    # Keep original state
    assert_same(original_state, Hypertension_U.state)
  end
end