require '../HyperTensioN/tests/hypest'

class Gardening < Test::Unit::TestCase
  include Hypest

  def test_plant_watering_pb1_ujshop_parsing
    parser_tests(
      # Files
      'examples/plant_watering/plant_watering.ujshop',
      'examples/plant_watering/pb1.ujshop',
      # Parser and extensions
      UJSHOP_Parser, [],
      # Attributes
      :domain_name => 'plant_watering',
      :problem_name => 'pb1',
      :operators => [
        ['move', ['?a', '?nx', '?ny'],
          # Preconditions
          ['agent', '?a'],
          # Effects
          [
            ['call', 'assign', ['x', '?a'], '?nx'],
            ['call', 'assign', ['y', '?a'], '?ny']
          ],
          [],
          # Probability
          1
        ],
        ['load', ['?a', '?t'],
          # Preconditions
          ['and',
            ['agent', '?a'],
            ['tap', '?t'],
            ['call', '=', ['call', 'function', ['x', '?a']], ['call', 'function', ['x', '?t']]],
            ['call', '=', ['call', 'function', ['y', '?a']], ['call', 'function', ['y', '?t']]],
            ['call', '<=', ['call', '+', ['call', 'function', 'total_loaded'], '1'], ['call', 'function', 'max_int']],
            ['call', '<=', ['call', '+', ['call', 'function', 'carrying'], '1'], ['call', 'function', 'max_int']]
          ],
          # Effects
          [
            ['call', 'increase', 'carrying', '1'],
            ['call', 'increase', 'total_loaded', '1']
          ],
          [],
          # Probability
          1
        ],
        ['pour', ['?a', '?p'],
          # Preconditions
          ['and',
            ['agent', '?a'],
            ['plant', '?p'],
            ['call', '=', ['call', 'function', ['x', '?a']], ['call', 'function', ['x', '?p']]],
            ['call', '=', ['call', 'function', ['y', '?a']], ['call', 'function', ['y', '?p']]],
            ['call', '>=', ['call', 'function', 'carrying'], '1'],
            ['call', '<=', ['call', '+', ['call', 'function', 'total_poured'], '1'], ['call', 'function', 'max_int']],
            ['call', '<=', ['call', '+', ['call', 'function', 'poured'], '1'], ['call', 'function', 'max_int']]
          ],
          # Effects
          [
            ['call', 'decrease', 'carrying', '1'],
            ['call', 'increase', ['poured', '?p'], '1'],
            ['call', 'increase', 'total_poured', '1']
          ],
          # Probability
          [],
          1
        ]
      ],
      :methods => [
        ['forward', ['?a', '?gx', '?gy'],
          ['base',
            # Preconditions
            ['and',
              ['call', '=', ['call', 'function', ['x', '?a']], '?gx'],
              ['call', '=', ['call', 'function', ['y', '?a']], '?gy']
            ],
            # Subtasks
            []
          ],
          ['keep_moving',
            ['adjacent', ['call', 'function', ['x', '?a']], ['call', 'function', ['y', '?a']], '?nx', '?ny', '?gx', '?gy'],
            # Subtasks
            [
              ['move', '?a', '?nx', '?ny'],
              ['forward', '?a', '?gx', '?gy']
            ]
          ]
        ],
        ['repeat', ['?n', '?task', '?a', '?tp'],
          ['task',
            # Preconditions
            ['call', '!=', '?n', '0'],
            # Subtasks
            [
              ['?task', '?a', '?tp'],
              ['repeat', ['call', '-', '?n', '1'], '?task', '?a', '?tp']
            ]
          ],
          ['base', [], []]
        ],
        ['move_to_load_before_move_to_pour', ['?p', '?l'],
          ['case_0',
            # Preconditions
            ['and',
              ['agent', '?a'],
              ['tap', '?t'],
              ['plant', '?p'],
              ['assign', '?tx', ['call', 'function', ['x', '?t']]],
              ['assign', '?ty', ['call', 'function', ['y', '?t']]],
              ['assign', '?px', ['call', 'function', ['x', '?p']]],
              ['assign', '?py', ['call', 'function', ['y', '?p']]]
            ],
            # Subtasks
            [
              ['forward', '?a', '?tx', '?ty'],
              ['repeat', '?l', 'load', '?a', '?t'],
              ['forward', '?a', '?px', '?py'],
              ['repeat', '?l', 'pour', '?a', '?p']
            ]
          ]
        ]
      ],
      :predicates => {
        'agent' => false,
        'plant' => false,
        'tap' => false
      },
      :state => [
        ['function', 'max_int', '20'],
        ['function', 'minx', '1'],
        ['function', 'maxx', '4'],
        ['function', 'miny', '1'],
        ['function', 'maxy', '4'],
        ['function', 'carrying', '0'],
        ['function', 'total_poured', '0'],
        ['function', 'total_loaded', '0'],
        ['agent', 'agent0'],
        ['function', ['x', 'agent0'], '1'],
        ['function', ['y', 'agent0'], '3'],
        ['tap', 'tap0'],
        ['function', ['x', 'tap0'], '4'],
        ['function', ['y', 'tap0'], '4'],
        ['plant', 'plant0'],
        ['function', ['x', 'plant0'], '2'],
        ['function', ['y', 'plant0'], '2'],
        ['function', ['poured', 'plant0'], '0']
      ],
      :tasks => [true, ['move_to_load_before_move_to_pour', 'plant0', '4']],
      :axioms => [],
      :rewards => [],
      :attachments => [['adjacent', '?x', '?y', '?nx', '?ny', '?gx', '?gy']]
    )
  end

  def test_plant_watering_pb1_ujshop_parsing_compile_to_rb
        compiler_tests(
      # Files
      'examples/plant_watering/plant_watering.ujshop',
      'examples/plant_watering/pb1.ujshop',
      # Parser and extensions
      UJSHOP_Parser, [], 'rb',
      # Domain
      "# Generated by Hype
require '#{File.expand_path('../../Hypertension_U', __FILE__)}'
require_relative 'external' if File.exist?(File.expand_path('../external.rb', __FILE__))

module Plant_watering
  include Hypertension_U
  extend self

  #-----------------------------------------------
  # Domain
  #-----------------------------------------------

  @domain = {
    # Operators
    'move' => 1,
    'load' => 1,
    'pour' => 1,
    # Methods
    'forward' => [
      'forward_base',
      'forward_keep_moving'
    ],
    'repeat' => [
      'repeat_task',
      'repeat_base'
    ],
    'move_to_load_before_move_to_pour' => [
      'move_to_load_before_move_to_pour_case_0'
    ]
  }

  #-----------------------------------------------
  # Operators
  #-----------------------------------------------

  def move(a, nx, ny)
    return unless @state['agent'].include?([a])
    External.assign(['x', a], nx) and External.assign(['y', a], ny)
  end

  def load(a, t)
    return unless (@state['agent'].include?([a]) and @state['tap'].include?([t]) and (External.function(['x', a]) == External.function(['x', t])) and (External.function(['y', a]) == External.function(['y', t])) and ((External.function('total_loaded').to_f + 1.0) <= External.function('max_int').to_f) and ((External.function('carrying').to_f + 1.0) <= External.function('max_int').to_f))
    External.increase('carrying', '1.0') and External.increase('total_loaded', '1.0')
  end

  def pour(a, p)
    return unless (@state['agent'].include?([a]) and @state['plant'].include?([p]) and (External.function(['x', a]) == External.function(['x', p])) and (External.function(['y', a]) == External.function(['y', p])) and (External.function('carrying').to_f >= 1.0) and ((External.function('total_poured').to_f + 1.0) <= External.function('max_int').to_f) and ((External.function('poured').to_f + 1.0) <= External.function('max_int').to_f))
    External.decrease('carrying', '1.0') and External.increase(['poured', p], '1.0') and External.increase('total_poured', '1.0')
  end

  #-----------------------------------------------
  # Methods
  #-----------------------------------------------

  def forward_base(a, gx, gy)
    return unless ((External.function(['x', a]) == gx) and (External.function(['y', a]) == gy))
    yield []
  end

  def forward_keep_moving(a, gx, gy)
    nx = ''
    ny = ''
    External.adjacent(External.function(['x', a]), External.function(['y', a]), nx, ny, gx, gy) {
      yield [
        ['move', a, nx, ny],
        ['forward', a, gx, gy]
      ]
    }
  end

  def repeat_task(n, task, a, tp)
    return unless (n.to_f != 0.0)
    yield [
      [task, a, tp],
      ['repeat', (n.to_f - 1.0).to_s, task, a, tp]
    ]
  end

  def repeat_base(n, task, a, tp)
    yield []
  end

  def move_to_load_before_move_to_pour_case_0(p, l)
    return unless ((px = External.function(['x', p])) and (py = External.function(['y', p])))
    a = ''
    t = ''
    generate(
      # Positive preconditions
      [
        ['agent', a],
        ['tap', t],
        ['plant', p]
      ],
      # Negative preconditions
      [], a, t
    ) {
      next unless ((tx = External.function(['x', t])) and (ty = External.function(['y', t])))
      yield [
        ['forward', a, tx, ty],
        ['repeat', l, 'load', a, t],
        ['forward', a, px, py],
        ['repeat', l, 'pour', a, p]
      ]
    }
  end
end",
      # Problem
      "# Generated by Hype
require_relative 'plant_watering.ujshop'

# Objects
max_int = 'max_int'
minx = 'minx'
maxx = 'maxx'
miny = 'miny'
maxy = 'maxy'
carrying = 'carrying'
total_poured = 'total_poured'
total_loaded = 'total_loaded'
agent0 = 'agent0'
_x_agent0 = ['x', 'agent0']
_y_agent0 = ['y', 'agent0']
tap0 = 'tap0'
_x_tap0 = ['x', 'tap0']
_y_tap0 = ['y', 'tap0']
plant0 = 'plant0'
_x_plant0 = ['x', 'plant0']
_y_plant0 = ['y', 'plant0']
_poured_plant0 = ['poured', 'plant0']

Plant_watering.problem(
  # Start
  {
    'agent' => [
      [agent0]
    ],
    'tap' => [
      [tap0]
    ],
    'plant' => [
      [plant0]
    ],
    'function' => [
      [max_int, '20.0'],
      [minx, '1.0'],
      [maxx, '4.0'],
      [miny, '1.0'],
      [maxy, '4.0'],
      [carrying, '0.0'],
      [total_poured, '0.0'],
      [total_loaded, '0.0'],
      [_x_agent0, '1.0'],
      [_y_agent0, '3.0'],
      [_x_tap0, '4.0'],
      [_y_tap0, '4.0'],
      [_x_plant0, '2.0'],
      [_y_plant0, '2.0'],
      [_poured_plant0, '0.0']
    ]
  },
  # Tasks
  [
    ['move_to_load_before_move_to_pour', plant0, '4.0']
  ],
  # Debug
  ARGV.first == 'debug',
  # Maximum plans found
  ARGV[1] ? ARGV[1].to_i : -1,
  # Minimum probability for plans
  ARGV[2] ? ARGV[2].to_f : 0
) or abort"
    )
  end
end