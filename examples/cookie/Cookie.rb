require_relative '../../Hypertension_U'

module Cookie
  include Hypertension_U
  extend self

  #-----------------------------------------------
  # Domain
  #-----------------------------------------------

  @domain = {
    # Operators
    'goto' => 1,
    'buy_cookie' => {
      'buy_good_cookie' => 0.8,
      'buy_bad_cookie' => 0.2
    },
    # Methods
    'get_cookie' => [
      'goto_and_buy_cookie'
    ]
  }

  #-----------------------------------------------
  # State valuation
  #-----------------------------------------------

  def state_valuation(old_state)
    previous_have = old_state[HAVE]
    current_have = @state[HAVE]
    bob__good_cookie = ['bob','good_cookie']
    bob__bad_cookie = ['bob','bad_cookie']
    value = 0
    value += 10 if not previous_have.include?(bob__good_cookie) and current_have.include?(bob__good_cookie)
    value -= 10 if not previous_have.include?(bob__bad_cookie) and current_have.include?(bob__bad_cookie)
    value
  end

  #-----------------------------------------------
  # Operators
  #-----------------------------------------------

  def goto(agent, from, to)
    apply_operator(
      # Positive preconditions
      [
        [AT, agent, from]
      ],
      # Negative preconditions
      [
        [AT, agent, to]
      ],
      # Add effects
      [
        [AT, agent, to]
      ],
      # Del effects
      [
        [AT, agent, from]
      ]
    )
  end

  def buy_good_cookie(agent)
    apply_operator(
      # Positive preconditions
      [
        [AT, agent, 'cookie_store']
      ],
      # Negative preconditions
      [],
      # Add effects
      [
        [HAVE, agent, 'good_cookie']
      ],
      # Del effects
      []
    )
  end

  def buy_bad_cookie(agent)
    apply_operator(
      # Positive preconditions
      [
        [AT, agent, 'cookie_store']
      ],
      # Negative preconditions
      [],
      # Add effects
      [
        [HAVE, agent, 'bad_cookie']
      ],
      # Del effects
      []
    )
  end

  #-----------------------------------------------
  # Methods
  #-----------------------------------------------

  def goto_and_buy_cookie(agent, from, to)
    yield [
      ['goto', agent, from, to],
      ['buy_cookie', agent]
    ]
  end
end