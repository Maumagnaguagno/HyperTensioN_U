#================================
# Methods to achieve agent goals
#================================

# (:method (achieveGoals)
#   workTowardsGoal
#   ((goal ?g ?gi ?a) (activeG ?g ?gi ?gv))
#   ((achieveGoal ?g ?gi ?a ?gv))
# )

def achieveGoals_workTowardsGoal
  g = ''
  gi = ''
  a = ''
  gv = ''
  generate(
    [
      ['goal', g, gi, a],
      ['activatedG', g, gi, gv]
    ],
    [], g, gi, a, gv
  ) {
    if activeG(g, gi, gv)
      yield [['achieveGoal', g, gi, a, gv]]
    end
  }
end

# (:method (achieveGoals)
#   activateGoal
#   ((goal ?g ?gi ?a) (goalPossible ?g ?gi ?gv))
#   ((!consider ?g ?gi ?a ?gv) (!activate ?g ?gi ?a ?gv) (achieveGoals))
#   noGoalsPossible
#   ()
#   ()
# )

def achieveGoals_activateGoal
  g = ''
  gi = ''
  a = ''
  gv = ''
  generate(
    [
      ['goal', g, gi, a],
      ['goalPossible', g, gi, gv]
    ],
    [], g, gi, a, gv
  ) {
    yield [
      ['consider', g, gi, a, gv],
      ['activate', g, gi, a, gv],
      ['achieveGoals']
    ]
  }
end

def achieveGoals_noGoalsPossible
  yield []
end

# (:method (achieveGoals)
#   multipleCommitments
#   ((goal ?g1 ?gi1 ?a1) (activeG ?g1 ?gi1 ?gv1) (goal ?g2 ?gi2 ?a2) (activeG ?g2 ?gi2 ?gv2) (commitment ?c1 ?ci1 ?a1 ?a2) (commitment ?c2 ?ci2 ?a2 ?a1) (eqGSCP ?g1 ?gv1 ?c1 ?cv1) (eqGSCP ?g2 ?gv2 ?c2 ?cv2))
#   ((entice ?g1 ?c1 ?a1 ?a2) (entice ?g2 ?c2 ?a2 ?a1) (detach ?c1 ?ci1 ?cv1) (detach ?c2 ?ci2 ?cv2))
# )

def achieveGoals_multipleCommitments
  g1 = ''
  gi1 = ''
  a1 = ''
  gv1 = ''
  g2 = ''
  gi2 = ''
  a2 = ''
  gv2 = ''
  c1 = ''
  ci1 = ''
  c2 = ''
  ci2 = ''
  cv1 = ''
  cv2 = ''
  # TODO verify definition of eqGSCP
  generate(
    [
      ['goal', g1, gi1, a1],
      ['activatedG', g1, gi1, gv1],
      ['goal', g2, gi2, a2],
      ['activatedG', g2, gi2, gv2],
      ['commitment', c1, ci1, a1, a2],
      ['commitment', c2, ci2, a2, a1],
      ['eqGSCP', g1, gv1, c1, cv1],
      ['eqGSCP', g2, gv2, c2, cv2]
    ],
    [], g1, gi1, a1, gv1, g2, gi2, a2, gv2, c1, ci1, c2, ci2, cv1, cv2
  ) {
    if activeG(g1, gi1, gv1) and activeG(g2, gi2, gv2)
      yield [
        ['entice', g1, c1, a1, a2],
        ['entice', g2, c2, a2, a1],
        ['detach', c1, ci1, cv1],
        ['detach', c2, ci2, cv2]
      ]
    end
  }
end

# (:method (achieveGoal ?g ?gi ?a ?gv)
#   genericEnticeToAchieve ;FM (2013/01/04): I'm deliberately forcing the variables of the commitment to be equal to those in the goal
#   ((activeG ?g ?gi ?gv) (goal ?g ?gi ?a) (commitment ?c ?ci ?a ?d) (assign ?cv ?gv) (eqGSCP ?g ?gv ?c ?cv) (goal ?g2 ?gi2 ?a) (assign ?gv2 ?cv) (eqGSCQ ?g2 ?gv2 ?c ?cv) (call != ?g ?g2))
#   ((entice ?g ?gi ?gv ?c ?ci ?cv ?a ?d) (detach ?c ?ci ?cv) (deliver ?g2 ?gi2 ?gv2 ?c ?ci ?cv ?a ?d) (achieveGoal ?g2 ?gi2 ?gv2 ?a))
# )

def achieveGoal_genericEnticeToAchieve(g, gi, a, gv)
  if activeG(g, gi, gv)
    c = ''
    ci = ''
    d = ''
    g2 = ''
    gi2 = ''
    gv2 = cv = gv
    # TODO verify definition of eqGSCP
    generate(
      [
        ['goal', g, gi, a],
        ['commitment', c, ci, a, d],
        ['eqGSCP', g, gv, c, cv],
        ['goal', g2, gi2, a],
        ['eqGSCQ', g2, gv2, c, cv]
      ],
      [], c, ci, d, g2, gi2, gv2
    ) {
      if g != g2
        yield [
          ['entice', g, gi, gv, c, ci, cv, a, d],
          ['detach', c, ci, cv],
          ['deliver', g2, gi2, gv2, c, ci, cv, a, d],
          ['achieveGoal', g2, gi2, gv2, a]
        ]
      end
    }
  end
end

# ;; Redo from here on before testing.
# (:method (achieveGoal g2 ?gi c)
#   ((activeG g2 ?gi) (goal g2 ?gi c))
#   ((!manufactureGoods c ?t))
# )

def achieveGoal_case1(parameter0, gi, parameter2)
  if parameter0 == 'g2' and parameter2 == 'c' and activeG('g2', gi) and state('goal', 'g2', gi, 'c')
    # TODO manufactureGoods is not a valid operator
    # TODO t variable is not bounded
    yield [['manufactureGoods', 'c', 't']]
  end
end

# (:method (achieveGoal g3 ?gi m)
#   ((activeG g3 ?gi) (goal g3 ?gi m))
#   ((!sendGoods m c ?t))
# )

def achieveGoal_case2(parameter0, gi, parameter2)
  if parameter0 == 'g3' and parameter2 == 'm' and activeG('g3', gi) and state('goal', 'g3', gi, 'm')
    # TODO sendGoods is not a valid operator
    # TODO t variable is not bounded
    yield [['sendGoods', 'm', 'c', 't']]
  end
end

# (:method (achieveGoal g4 ?gi c)
#   ((activeG g4 ?gi) (goal g4 ?gi c))
#   ((!sendPayment c m ?t))
# )

def achieveGoal_case3(parameter0, gi, parameter2)
  if parameter0 == 'g4' and parameter2 == 'c' and activeG('g4', gi) and state('goal', 'g4', gi, 'c')
    # TODO sendPayment is not a valid operator
    # TODO t variable is not bounded
    yield [['sendPayment', 'c', 'm', 't']]
  end
end

# (:method (detach ?c ?ci)
#   ((call = ?c c1) (active ?c ?ci) (commitment ?c ?ci ?a ?d)) ;FM (2013/01/17) Changed the precondition to be more generic
#   ((!sendPayment ?d ?a ?t)) ;FM Was ((!sendPayment c m ?t))
#   ((call = ?c c5) (active ?c ?ci) (commitment ?c ?ci ?a ?d)) ;FM (2013/01/17) Changed the precondition to be more generic
#   ((!sendGoods ?d ?a ?t)) ; FM Was ((!sendGoods m c ?t))
# )

def detach_case0(c, ci)
  # TODO sendPayment is not a valid operator
  # TODO sendGoods is not a valid operator
  # TODO t variable is not bounded
  if c == 'c1' and active(c, ci)
    a = ''
    d = ''
    generate(
      [['commitment', c, ci, a, d]],
      [], a, d
    ) {
      yield [['sendPayment', d, a, 't']]
    }
  elsif c == 'c5' and active(c, ci)
    a = ''
    d = ''
    generate(
      [['commitment', c, ci, a, d]],
      [], a, d
    ) {
      yield [['sendGoods', d, a, 't']]
    }
  end
end