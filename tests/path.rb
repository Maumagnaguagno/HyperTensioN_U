require './tests/hypest'

class Path < Test::Unit::TestCase
  include Hypest

  def test_search_angle_pb1_ujshop_parsing
    parser_tests(
      # Files
      'examples/search_angle/search.ujshop',
      'examples/search_angle/pb1.ujshop',
      # Parser and extensions
      UJSHOP_Parser, [],
      # Attributes
      :domain_name => 'search',
      :problem_name => 'pb1',
      :operators => [
        ['move', ['?agent', '?from', '?to'],
          # Preconditions
          ['and',
            ['at', '?agent', '?from'],
            ['call', 'visible', '?from', '?to']
          ],
          # Effects
          [['at', '?agent', '?to']],
          [['at', '?agent', '?from']],
          # Probability
          1
        ],
        ['invisible_visit', ['?agent', '?pos'],
          # Preconditions
          [],
          # Effects
          [['visited', '?agent', '?pos']],
          [],
          # Probability
          1
        ],
        ['invisible_unvisit', ['?agent', '?pos'],
          # Preconditions
          [],
          # Effects
          [],
          [['visited', '?agent', '?pos']],
          # Probability
          1
        ]
      ],
      :methods => [
        ['forward', ['?agent', '?goal'],
          ['base',
            # Preconditions
            ['at', '?agent', '?goal'],
            # Subtasks
            [],
          ],
          ['goal-visible',
            # Preconditions
            ['and',
              ['at', '?agent', '?from'],
              ['call', 'visible', '?from', '?goal']
            ],
            # Subtasks
            [['move', '?agent', '?from', '?goal']]
          ],
          ['recursion',
            # Preconditions
            ['and',
              ['at', '?agent', '?from'],
              ['visible-vertex', '?from', '?vertex'],
              ['arc', '?from', '?vertex', '?place'],
              ['not', ['visited', '?agent', '?vertex']],
            ],
            # Subtasks
            [
              ['move', '?agent', '?from', '?place'],
              ['invisible_visit', '?agent', '?vertex'],
              ['forward', '?agent', '?goal'],
              ['invisible_unvisit', '?agent', '?vertex']
            ]
          ]
        ]
      ],
      :predicates => {
        'at' => true,
        'visited' => true
      },
      :state => [['at', 'robot', 'start']],
      :tasks => [true, ['forward', 'robot', 'goal']],
      :axioms => [],
      :rewards => [],
      :attachments => [
        ['arc', '?from', '?to', '?arc_to'],
        ['visible-vertex', '?from', '?vertex']
      ]
    )
  end
end