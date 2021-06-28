require '../HyperTensioN/tests/hypest'

class Biscuit < Test::Unit::TestCase
  include Hypest

  def test_cookie_pb1_ujshop_parsing
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
          1
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
          ['goto_and_buy_cookie',
            # Preconditions
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
      :state => {'at' => [['bob', 'home']]},
      :tasks => [true, ['get_cookie', 'bob', 'home', 'cookie-store']],
      :axioms => [],
      :rewards => [
        ['achieve', ['have', 'bob', 'good-cookie'], '10'],
        ['achieve', ['have', 'bob', 'bad-cookie'], '-10']
      ],
      :attachments => []
    )
  end

  def test_cookie_pb1_ujshop_parsing_compile_to_rb
    compiler_tests(
      # Files
      'examples/cookie/cookie.ujshop',
      'examples/cookie/pb1.ujshop',
      # Parser and extensions
      UJSHOP_Parser, [], 'rb',
      # Domain
      "# Generated by Hype
require '#{File.expand_path('../../Hypertension_U', __FILE__)}'
require_relative 'external' if File.exist?(\"\#{__dir__}/external.rb\")

module Cookie
  include Hypertension_U
  extend self

  #-----------------------------------------------
  # Domain
  #-----------------------------------------------

  @domain = {
    # Operators
    'goto' => 1.0,
    'buy_cookie' => {
      'buy_good_cookie' => 0.8,
      'buy_bad_cookie' => 0.2
    },
    # Methods
    'get_cookie' => [
      'get_cookie_goto_and_buy_cookie'
    ]
  }

  #-----------------------------------------------
  # State valuation
  #-----------------------------------------------

  def state_valuation(old_state)
    value = 0
    value += 10 if not old_state['have'].include?(['bob', 'good_cookie']) and @state['have'].include?(['bob', 'good_cookie'])
    value += -10 if not old_state['have'].include?(['bob', 'bad_cookie']) and @state['have'].include?(['bob', 'bad_cookie'])
    value
  end

  #-----------------------------------------------
  # Operators
  #-----------------------------------------------

  def goto(agent, from, to)
    return unless (@state['at'].include?([agent, from]) and not @state['at'].include?([agent, to]))
    @state = @state.dup
    (@state['at'] = @state['at'].dup).delete([agent, from])
    @state['at'].unshift([agent, to])
  end

  def buy_good_cookie(agent)
    return unless @state['at'].include?([agent, 'cookie_store'])
    @state = @state.dup
    (@state['have'] = @state['have'].dup).unshift([agent, 'good_cookie'])
  end

  def buy_bad_cookie(agent)
    return unless @state['at'].include?([agent, 'cookie_store'])
    @state = @state.dup
    (@state['have'] = @state['have'].dup).unshift([agent, 'bad_cookie'])
  end

  #-----------------------------------------------
  # Methods
  #-----------------------------------------------

  def get_cookie_goto_and_buy_cookie(agent, from, to)
    yield [
      ['goto', agent, from, to],
      ['buy_cookie', agent]
    ]
  end
end",
      # Problem
      "# Generated by Hype
require_relative 'cookie.ujshop'

# Objects
bob = 'bob'
home = 'home'
cookie_store = 'cookie_store'

Cookie.problem(
  # Start
  {
    'at' => [
      [bob, home]
    ],
    'have' => []
  },
  # Tasks
  [
    ['get_cookie', bob, home, cookie_store]
  ],
  # Debug
  ARGV.first == 'debug',
  # Maximum plans found
  ARGV[1] ? ARGV[1].to_i : -1,
  # Minimum probability for plans
  ARGV[2] ? ARGV[2].to_f : 0
)"
    )
  end
end