# Generated by Hype
require_relative '../../Hypertension_U'

module Disjunction
  include Hypertension_U
  extend self

  #-----------------------------------------------
  # Domain
  #-----------------------------------------------

  @domain = {
    # Operators
    'op' => 1,
    # Methods
    'unify' => [
      'unify_case_0'
    ]
  }

  #-----------------------------------------------
  # Axioms
  #-----------------------------------------------

  def axiom1(parameter0, parameter1, parameter2)
    # case 0
    true if (@state['p'].include?([parameter0, parameter1]) and (@state['q'].include?([parameter0]) or @state['r'].include?([parameter1]) or @state['s'].include?([parameter2])))
  end

  def axiom1_unifier(parameter0, parameter1, parameter2)
    free_vars = []
    free_vars << parameter0 if parameter0.empty?
    free_vars << parameter1 if parameter1.empty?
    generate(
      [
        ['p', parameter0, parameter1]
      ],
      [],
      *free_vars
    ) {
      if @state['q'].include?([parameter0]) then yield
      elsif @state['r'].include?([parameter1]) then yield
      elsif parameter2.empty?
        generate(
          [
            ['s', parameter2]
          ],
          [],
          parameter2
        ) {
          yield
        }
      elsif @state['s'].include?([parameter2]) then yield
      end
    }
  end

  #-----------------------------------------------
  # Operators
  #-----------------------------------------------

  def op(z, x, y)
    true
  end

  #-----------------------------------------------
  # Methods
  #-----------------------------------------------

  def unify_case_0(z)
    if @state['pred'].include?([z])
      x = ''
      y = ''
      axiom1_unifier(z, x, y) {
        yield [
          ['op', z, x, y]
        ]
      }
    end
  end
end