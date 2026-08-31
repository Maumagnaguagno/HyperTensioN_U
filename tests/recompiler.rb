require 'test/unit'
require './Hype'

class Recompiler < Test::Unit::TestCase

  def intermediate_representation(parser)
    [
      parser.domain_name,
      parser.problem_name,
      parser.operators,
      parser.methods,
      parser.predicates,
      parser.state,
      parser.tasks,
      parser.axioms,
      parser.rewards,
      parser.attachments
    ]
  end

  def compile(ir)
    expected = Marshal.load(Marshal.dump(ir))
    UHyper_Compiler.compile_domain(*ir)
    UHyper_Compiler.compile_problem(*ir)
    assert_equal(expected, ir)
  end

  def test_cookie_pb1_pddl_compilation
    UJSHOP_Parser.parse_domain('examples/cookie/cookie.ujshop')
    UJSHOP_Parser.parse_problem('examples/cookie/pb1.ujshop')
    compile(intermediate_representation(UJSHOP_Parser))
  end
end