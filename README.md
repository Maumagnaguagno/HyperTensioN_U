# HyperTensioN U [![Build Status](https://travis-ci.org/Maumagnaguagno/HyperTensioN_U.svg)](https://travis-ci.org/Maumagnaguagno/HyperTensioN_U)
**Hierarchical Task Network planning with uncertainty in Ruby**

This is a modified version of [HyperTensioN](https://github.com/Maumagnaguagno/HyperTensioN) to work with probabilities and rewards.
A simpler version of this can be found [here](https://github.com/Maumagnaguagno/HyperTensioN/blob/2226edbd967f42cea63c986a4a0ed71415bdc5e6/old_versions/simple/Hypertension_simple.rb).
As always Hype can help you in the conversion process, from UJSHOP to Ruby, but you can ignore the Hype and use Hypertension U as a standalone library.

```Shell
Usage:
    Hype domain problem output

  Output:
    rb    - generate Ruby files to Hypertension U(default)
    run   - same as rb with execution
    debug - same as run with execution log
```

To execute the [cookie example](examples/cookie) is simple:

```Shell
ruby Hype.rb examples/cookie/cookie.ujshop examples/cookie/pb1.ujshop run
```

## UJSHOP
The expected input for HyperTensioN U is based on a modified version of the JSHOP formalism.
Two files define domain and problem as a planning instance.
The domain defines the rules that never change, while the problem defines a situation that requires planning.
Several problems may refer to the same domain, as many situations may happen within the same constraints.
Differently from JSHOP descriptions the operators may have uncertain effects with known probabilities.

### Domain

```Lisp
; This is a comment line
(defdomain domain-name (

  ; Reward function
  (:reward
    ((pre1 a)  10) ; Obtaining (pre1 a) from one state to another adds 10 to valuation
    ((pre2 b) -10) ; Any integer can be a reward, even negative values
  )

  (:operator (!op-name1 ?t1 ?t2)
    ; Preconditions
    () ; empty set
    ; Del effects
    nil ; also empty
    ; Add effects
    (
      (pre1 ?t2)
    )
    ; Probability
    1 ; 100% is the default probability
  )

  (:operator (!op-name2 ?t1)
    ; Preconditions
    ()
    op-name2-label1 ; label can be omitted, otherwise must be unique
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
    label ; label can be omitted, otherwise must be unique
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
(defproblem problem-name doman-name
  ; Start with this ground predicates as true
  (
    (pre1 object)
  )
  ; Tasks to be executed
  (
    (method-name object another-object)
  )
  ; Reward function, TODO to be supported in a future version
  ;(:reward
  ;  ((pre1 book) 5) ; Problem rewards add/overwrite domain rewards
  ;)
)
```

## ToDo's
- Add support for axioms
- Add support for problem rewards
- Add examples
- Don't add internal operators (prefix ``!!``) to plan