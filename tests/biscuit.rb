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
      # Extensions and output
      [], 'rb',
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

  def goto(_agent, _from, _to)
    return unless (@state['at'].include?([_agent, _from]) and not @state['at'].include?([_agent, _to]))
    @state = @state.dup
    (@state['at'] = @state['at'].dup).delete([_agent, _from])
    @state['at'].unshift([_agent, _to])
  end

  def buy_good_cookie(_agent)
    return unless @state['at'].include?([_agent, 'cookie_store'])
    @state = @state.dup
    (@state['have'] = @state['have'].dup).unshift([_agent, 'good_cookie'])
  end

  def buy_bad_cookie(_agent)
    return unless @state['at'].include?([_agent, 'cookie_store'])
    @state = @state.dup
    (@state['have'] = @state['have'].dup).unshift([_agent, 'bad_cookie'])
  end

  #-----------------------------------------------
  # Methods
  #-----------------------------------------------

  def get_cookie_goto_and_buy_cookie(_agent, _from, _to)
    yield [
      ['goto', _agent, _from, _to],
      ['buy_cookie', _agent]
    ]
  end
end",
      # Problem
      "# Generated by Hype
require_relative 'cookie.ujshop'

# Objects
_bob = 'bob'
_home = 'home'
_cookie_store = 'cookie_store'

Cookie.problem(
  # Start
  {
    'at' => [
      [_bob, _home]
    ],
    'have' => []
  },
  # Tasks
  [
    ['get_cookie', _bob, _home, _cookie_store]
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