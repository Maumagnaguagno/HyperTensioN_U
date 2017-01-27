# HyperTensioN U [![Build Status](https://travis-ci.org/Maumagnaguagno/HyperTensioN_U.svg)](https://travis-ci.org/Maumagnaguagno/HyperTensioN_U)
**Hierarchical Task Network planning with uncertainty in Ruby**

This is a modified version of [HyperTensioN](https://github.com/Maumagnaguagno/HyperTensioN) to work with probabilities and rewards, currently **incompatible** with the original.
Hype can help you in the conversion process from [UJSHOP](#ujshop "Jump to UJSHOP section") to Ruby, but you can ignore the Hype and use Hypertension U as a standalone library.

```Shell
Usage:
    Hype domain problem output [-d] [max plans=-1(all)] [minprobability=0]\n

  Output:
    rb    - generate Ruby files to Hypertension U(default)
    run   - same as rb with execution
    debug - same as run with execution log
```

An example in both Ruby and UJSHOP formalism is given.
To convert and execute the [cookie example](examples/cookie) is simple:

```Shell
ruby Hype.rb examples/cookie/cookie.ujshop examples/cookie/pb1.ujshop run
```

Or call the Ruby problem:

```Shell
# Use debug with -d option
ruby examples/cookie/pb1.rb -d
# No need to call Hype twice, the problem will load the domain
ruby examples/cookie/pb1.ujshop.rb -d
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
(defproblem problem-name doman-name
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

## ToDo's
- Test compiled output
- Support expressions in method preconditions