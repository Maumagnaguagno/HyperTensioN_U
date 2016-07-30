require './tests/hypest'

class Biscuit < Test::Unit::TestCase
  include Hypest

  def test_cookie_ujshop_parsing
    parser_tests(
      # Files
      'examples/cookie/cookie.ujshop',
      'examples/cookie/pb1.ujshop',
      # Parser and extensions
      UJSHOP_Parser, [],
      # Attributes
      :domain_name => 'cookie',
      :problem_name => 'pb1',
      :operators => [
        ['goto', ['?agent', '?from', '?to'],
          # Preconditions
          ['and',
            ['at', '?agent', '?from'],
            ['not', ['at', '?agent', '?to']]
          ],
          # Effects
          [['at', '?agent', '?to']],
          [['at', '?agent', '?from']],
          # Probability
          1.0
        ],
        ['buy_cookie', ['?agent'],
          # Preconditions
          ['at', '?agent', 'cookie-store'],
          #  Effects label
          'buy_good_cookie',
          # Effects
          [['have', '?agent', 'good-cookie']],
          [],
          # Probability
          0.8,
          # Effects label
          'buy_bad_cookie',
          # Effects
          [['have', '?agent', 'bad-cookie']],
          [],
          # Probability
          0.2
        ]
      ],
      :methods => [
        ['get_cookie', ['?agent', '?from', '?to'],
          ['goto_and_buy_cookie', [],
            # Preconditions
            [],
            [],
            # Subtasks
            [
              ['goto', '?agent', '?from', '?to'],
              ['buy_cookie', '?agent']
            ]
          ]
        ]
      ],
      :predicates => {
        'at' => true,
        'have' => true
      },
      :state => [['at', 'bob', 'home']],
      :tasks => [true, ['get_cookie', 'bob', 'home', 'cookie-store']],
      :goal_pos => [],
      :goal_not => []
    )
  end
end