# HyperTensioN U [![Actions Status](https://github.com/Maumagnaguagno/HyperTensioN_U/workflows/build/badge.svg)](https://github.com/Maumagnaguagno/HyperTensioN_U/actions)
**Hierarchical Task Network planning with uncertainty in Ruby**

This is an extension of [HyperTensioN](https://github.com/Maumagnaguagno/HyperTensioN) to work with disjunctions, probabilities, rewards, axioms, assignments, calls and semantic attachments, currently **incompatible** with the original intermediate representation.
Hype can help you in the conversion process from [UJSHOP](#ujshop "Jump to UJSHOP section") to Ruby, but you can ignore the Hype and use HyperTensioN U as a standalone library.

```
Usage:
    Hype domain problem [output] [max plans=-1(all)] [min probability=0]

  Output:
    rb    - generate Ruby files to HyperTensioN U(default)
    run   - same as rb with execution
    debug - same as run with execution log
```

To convert and execute the [cookie example](examples/cookie) is simple:

```Shell
ruby Hype.rb examples/cookie/cookie.ujshop examples/cookie/pb1.ujshop run
```

Or call the Ruby problem:

```Shell
# Use with debug option
ruby examples/cookie/pb1.rb debug
# No need to call Hype twice, the problem will load the domain
ruby examples/cookie/pb1.ujshop.rb debug
```

## UJSHOP
The expected input for HyperTensioN U is based on a modified version of the JSHOP formalism.
Two files define domain and problem as a planning instance.
The domain defines the rules that never change, while the problem defines a situation that requires planning.
Several problems may refer to the same domain, as many situations may happen within the same constraints.
Differently from JSHOP descriptions the operators may have uncertain effects with known probabilities instead of a cost.
Rewards are used to better evaluate which plan is better, instead of the total plan cost.
External function calls and semantic attachments are also available.

### Domain
```Lisp
; This is a comment line
(defdomain domain-name (

  ; Reward function
  (:rewards ; Any numeric can be a reward
    (achieve  (pre1 a)  10)  ; Obtaining (pre1 a) from one state to another adds 10 to valuation
    (maintain (pre2 b) -0.5) ; Keeping (pre2 b) from one state to another subtracts 0.5 from valuation
  )

  (:operator (!op-name1 ?t1 ?t2)
    ; Preconditions
    () ; empty set
    ; Del effects
    ()
    ; Add effects
    (
      (pre1 ?t2)
    )
    ; Probability
    1 ; 100% is the default probability
  )

  (:operator (!op-name2 ?t1)
    ; Preconditions
    (and ; Expressions with AND OR NOT are supported by operator preconditions, AND can be omitted
      (pre1 ?t1)
      (pre2 ?t1)
    )
    op-name2-label1 ; Label can be omitted, otherwise must be unique
    ; Del effects
    (
      (pre3 ?t1)
    )
    ; Add effects
    ()
    0.8 ; 80% probability
    op-name2-label2 ; Another set of effects for this action
    ; Del effects
    ()
    ; Add effects
    (
      (pre3 ?t1)
    )
    0.2 ; 20% probability
  )

  (:method (method-name ?t1 ?t2)
    label ; Label can be omitted, otherwise must be unique
    ; Preconditions
    (
      (pre1 ?t1)
      (not (pre2 ?t2))
    )
    ; Subtasks
    (
      (!op-name1 ?t1)
      (method-name ?t2 ?t1)
    )
    ; Other decompositions for the method may be put here
  )
))
```

### Problem
```Lisp
(defproblem problem-name domain-name
  ; Start with this ground predicates as true
  (
    (pre1 object)
  )
  ; Tasks to be executed
  (
    (method-name object another-object)
  )
)
```

## Function calls
Sometimes functions must be called to solve a problem beyond the reach of declarative descriptions.
Basic functions are already implemented:
- Binary math ``+``, ``-``, ``*``, ``/``, ``%``, ``^``
- Unary math ``abs``, ``sin``, ``cos``, ``tan``
- Comparison ``=``, ``!=``, ``<``, ``>``, ``<=``, ``>=``
- List ``member``

```Lisp
(call < (call abs (call - (call sin ?var) 0.5)) 1)
```

Other functions can be used through external calls the user implements in the ``external.rb`` file in the same folder as the domain.
The ``external.rb`` must define an **External** module with methods that are expected to return String objects, numbers are expected to be in the Float format (``5.to_f.to_s == "5.0"``).
This is a requirement of the ``generate`` method that expects Strings to replace variables, if you only need to forward values through subtasks you can ignore this limitation.
Calls that only operate on external structures must return any non-false value to avoid failing preconditions.
Instance variables from HyperTensioN U can be accessed by using the domain namespace, such as ``Mydomain.state``.
An example of calls is available at [examples/external](examples/external).
Note that the state of external structures is not implicitly saved, which may impact search results that try to decompose using other methods or operator effects.
To avoid this problem one can limit the number of plans to be searched, add more preconditions or explicitly duplicate such structures.
The most common case is what would happen if a task consumed an element from the queue and later on failed, that element would not be in the queue anymore and a different decomposition would take place.
Meta calls are possible through ``send`` to use variables as function names, ``(call send ?function ?param1 ?param2)``.

## Assignments
The result of an expensive call may be necessary across several terms.
Instead of repeating the entire call, one can create a new variable and assign the value of such call.
Assignments are limited to preconditions.

```Lisp
(assign ?newvar (call - ?var 5))
```

## Semantic Attachments
Some predicates are too complex for the user to describe with addition and deletion effects from the state, like ``(visible ?agent ?object)`` after ``?agent`` is moved.
These predicates either require external structures or libraries to be fast and easy to maintain.
Instead of using calls in unusual ways to discover all the objects that are visible for a certain agent, we can exploit off-the-shelf libraries and delegate this unification to an external procedure.
Such external methods are semantic attachments, a term coined by [Weyhrauch (1980)](http://www.sciencedirect.com/science/article/pii/0004370280900156 "Prolegomena to a theory of mechanized formal reasoning") to describe the attachment of an interpretation to a predicate symbol using an external procedure.
Semantic attchments in planning was already explored by [Christian Dornhege et al. (2009)](https://www.aaai.org/ocs/index.php/ICAPS/ICAPS09/paper/viewFile/754/1101 "Semantic attachments for domain-independent planning systems").
A semantic attachment signature must be explicitly defined as such and can be used as regular predicates in preconditions.

```Lisp
(:attachments (visible ?agent ?object))
```

Semantic attachment are defined in ``external.rb``, like external calls, but implemented to ``yield`` unifications instead of ``return`` values.
Free variables are used as terms and expected to be assigned by the semantic attachment to possible values before resuming control back to the HTN, or return in case of failure to unify more values.
Since all variables are Strings the semantic attachment implementation must replace all empty Strings, free variables, with actual values before yielding.
The same semantic attachment can be repeatedly used to unify different free variables.
Ground variables are not expected to be replaced, in case all variables are ground the semantic attachment yields if the current values satisfy.
An example of semantic attachments is available at [examples/search_circular](examples/search_circular).

```Ruby
def visible(agent, object)
  pos = POSITION[agent]
  # Agent is ground and object is free
  if object.empty?
    MAP[pos].each {|obj|
      object.replace(obj)
      yield
    }
  # Both variables are ground
  elsif MAP[pos].include?(object)
    yield
  end
end
```

## ToDo's
- Add list variable support
- Support complex expressions in method preconditions