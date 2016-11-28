require './tests/hypest'

class Postulate < Test::Unit::TestCase
  include Hypest

  def test_axiom_ujshop_parsing
    parser_tests(
      # Files
      'examples/axiom/axiom.ujshop',
      'examples/axiom/pb1.ujshop',
      # Parser and extensions
      UJSHOP_Parser, [],
      # Attributes
      :domain_name => 'axiom',
      :problem_name => 'pb1',
      :operators => [
        ['add-one', ['?current'],
          # Preconditions
          ['and',
            ['empty_axiom', '?current'],
            ['at-axiom', '?current']
          ],
          # Effects
          [['at', ['call', '+', '?current', '1']]],
          [['at', '?current']],
          # Probability
          1.0
        ]
      ],
      :methods => [],
      :predicates => {'at' => true},
      :state => [['at', '0']],
      :tasks => [true,
        ['add-one', '0'],
        ['add-one', '1'],
        ['add-one', '2']
      ],
      :axioms => [
        ['empty_axiom', ['?parameter0'],
          'negate-empty-list',
          ['not', []]
        ],
        ['at-axiom', ['?parameter0'],
          'numeric-constant',
          ['and',
            ['call', '=', '?parameter0', '0'],
            ['at', '0'],
          ],
          'double-negation',
          ['not', ['not', ['at', '?parameter0']]]
        ]
      ],
      :reward => []
    )
  end
end