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
  generate(
    [
      ['goal', g1, gi1, a1],
      ['activatedG', g1, gi1, gv1],
      ['goal', g2, gi2, a2],
      ['activatedG', g2, gi2, gv2],
      ['commitment', c1, ci1, a1, a2],
      ['commitment', c2, ci2, a2, a1]
    ],
    [], g1, gi1, a1, gv1, g2, gi2, a2, gv2, c1, ci1, c2, ci2
  ) {
    # TODO eqGSCP may have multiple unifications for cv1 and cv2
    cv1 = ''
    cv2 = ''
    if activeG(g1, gi1, gv1) and activeG(g2, gi2, gv2) and eqGSCP(g1, gv1, c1, cv1) and eqGSCP(g2, gv2, c2, cv2)
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
    generate(
      [
        ['goal', g, gi, a],
        ['commitment', c, ci, a, d],
        ['goal', g2, gi2, a]
      ],
      [], c, ci, d, g2, gi2
    ) {
      gv2 = cv = gv
      if g != g2 and eqGSCP(g, gv, c, cv) and eqGSCQ(g2, gv2, c, cv)
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