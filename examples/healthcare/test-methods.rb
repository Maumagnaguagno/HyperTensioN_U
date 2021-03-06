#=========================
# Methods to test the rules
#=========================

# (:method (testCommitment ?c ?ci ?cv ?s)
#   ((commitment ?c ?ci ?d ?a) (call = ?s null) (null ?c ?ci ?cv))
#   ((!!testSuccess ?c ?ci ?cv ?s))

#   ((commitment ?c ?ci ?d ?a) (call = ?s conditional) (conditional ?c ?ci ?cv))
#   ((!!testSuccess ?c ?ci ?cv ?s))

#   ((commitment ?c ?ci ?d ?a) (call = ?s active) (active ?c ?ci ?cv))
#   ((!!testSuccess ?c ?ci ?cv ?s))

#   ((commitment ?c ?ci ?d ?a) (call = ?s nactive) (not (active ?c ?ci ?cv)))
#   ((!!testSuccess ?c ?ci ?cv ?s))

#   ((commitment ?c ?ci ?d ?a) (call = ?s detached) (detached ?c ?ci ?cv))
#   ((!!testSuccess ?c ?ci ?cv ?s))

#   ((commitment ?c ?ci ?d ?a) (call = ?s expired) (expired ?c ?ci ?cv))
#   ((!!testSuccess ?c ?ci ?cv ?s))

#   ((commitment ?c ?ci ?d ?a) (call = ?s pending) (pending ?c ?ci ?cv))
#   ((!!testSuccess ?c ?ci ?cv ?s))

#   ((commitment ?c ?ci ?d ?a) (call = ?s terminated) (terminated ?c ?ci ?cv))
#   ((!!testSuccess ?c ?ci ?cv ?s))

#   ((commitment ?c ?ci ?d ?a) (call = ?s violated) (violated ?c ?ci ?cv))
#   ((!!testSuccess ?c ?ci ?cv ?s))

#   ((commitment ?c ?ci ?d ?a) (call = ?s satisfied) (satisfied ?c ?ci ?cv))
#   ((!!testSuccess ?c ?ci ?cv ?s))

#   ((commitment ?c ?ci ?d ?a) (call = ?s cancelled) (cancelled ?c ?ci ?cv))
#   ((!!testSuccess ?c ?ci ?cv ?s))

#   ((commitment ?c ?ci ?d ?a) (call = ?s terminal) (terminal ?c ?ci ?cv))
#   ((!!testSuccess ?c ?ci ?cv ?s))

#   ((commitment ?c ?ci ?d ?a) (call = ?s p) (p ?c ?ci ?cv))
#   ((!!testSuccess ?c ?ci ?cv ?s))

#   ((commitment ?c ?ci ?d ?a) (call = ?s q) (q ?c ?ci ?cv))
#   ((!!testSuccess ?c ?ci ?cv ?s))

#   failed
#   ((commitment ?c ?ci ?d ?a))
#   ((!!testFailure ?c ?ci ?s))
# )

def testCommitment_case0(c, ci, cv, s)
  if @state[COMMITMENT].any? {|terms| terms.size == 4 and terms[0] == c and terms[1] == ci}
    if (s == 'null' and null(c, ci, cv)) or
       (s == 'conditional' and conditional(c, ci, cv)) or
       (s == 'active' and active(c, ci, cv)) or
       (s == 'nactive' and not active(c, ci, cv)) or
       (s == 'detached' and detached(c, ci, cv)) or
       (s == 'expired' and state(EXPIRED, c, ci, cv)) or
       (s == 'pending' and state(PENDING, c, ci, cv)) or
       (s == 'terminated' and terminated(c, ci, cv)) or
       (s == 'violated' and violated(c, ci, cv)) or
       (s == 'satisfied' and satisfied(c, ci, cv)) or
       (s == 'cancelled' and state(CANCELLED, c, ci, cv)) or
       (s == 'terminal' and terminal(c, ci, cv)) or
       (s == 'p' and p(c, ci, cv)) or
       (s == 'q' and q(c, ci, cv))
      yield [['invisible_testSuccess', c, ci, cv, s]]
    else
      yield [['invisible_testFailure', c, ci, s]]
    end
  end
end

# (:method (testGoal ?g ?gi ?gv ?s)
#   ((goal ?g ?gi ?a) (call = ?s null) (nullG ?g ?gi ?gv))
#   ((!!testSuccessG ?g ?gi ?gv ?s))

#   ((goal ?g ?gi ?a) (call = ?s inactive) (inactiveG ?g ?gi ?gv))
#   ((!!testSuccessG ?g ?gi ?gv ?s))

#   ((goal ?g ?gi ?a) (call = ?s ninactive) (not (inactiveG ?g ?gi ?gv)))
#   ((!!testSuccessG ?g ?gi ?gv ?s))

#   ((goal ?g ?gi ?a) (call = ?s active) (activeG ?g ?gi ?gv))
#   ((!!testSuccessG ?g ?gi ?gv ?s))

#   ((goal ?g ?gi ?a) (call = ?s nactive) (not (activeG ?g ?gi ?gv)))
#   ((!!testSuccessG ?g ?gi ?gv ?s))

#   ((goal ?g ?gi ?a) (call = ?s suspended) (suspendedG ?g ?gi ?gv))
#   ((!!testSuccessG ?g ?gi ?gv ?s))

#   ((goal ?g ?gi ?a) (call = ?s nsuspended) (not (suspendedG ?g ?gi ?gv)))
#   ((!!testSuccessG ?g ?gi ?gv ?s))

#   ((goal ?g ?gi ?a) (call = ?s terminated) (terminatedG ?g ?gi ?gv))
#   ((!!testSuccessG ?g ?gi ?gv ?s))

#   ((goal ?g ?gi ?a) (call = ?s failed) (failed ?g ?gi ?gv))
#   ((!!testSuccessG ?g ?gi ?gv ?s))

#   ((goal ?g ?gi ?a) (call = ?s satisfied) (satisfiedG ?g ?gi ?gv))
#   ((!!testSuccessG ?g ?gi ?gv ?s))

#   ((goal ?g ?gi ?a) (call = ?s nsatisfied) (not (satisfiedG ?g ?gi ?gv)))
#   ((!!testSuccessG ?g ?gi ?gv ?s))

#   ((goal ?g ?gi ?a) (call = ?s terminal) (terminalG ?g ?gi ?gv))
#   ((!!testSuccessG ?g ?gi ?gv ?s))

#   failed
#   ((goal ?g ?gi ?a))
#   ((!!testFailure ?g ?gi ?s))
# )

def testGoal_case0(g, gi, gv, s)
  if @state[GOAL].any? {|terms| terms.size == 3 and terms[0] == g and terms[1] == gi}
    if (s == 'null' and nullG(g, gi, gv)) or
       (s == 'inactive' and inactiveG(g, gi, gv)) or
       (s == 'ninactive' and not inactiveG(g, gi, gv)) or
       (s == 'active' and activeG(g, gi, gv)) or
       (s == 'nactive' and not activeG(g, gi, gv)) or
       (s == 'suspended' and state(SUSPENDEDG, g, gi, gv)) or
       (s == 'nsuspended' and not state(SUSPENDEDG, g, gi, gv)) or
       (s == 'terminated' and terminatedG(g, gi, gv)) or
       (s == 'failed' and state(FAILED, g, gi, gv)) or
       (s == 'satisfied' and satisfiedG(g, gi, gv)) or
       (s == 'nsatisfied' and not satisfiedG(g, gi, gv)) or
       (s == 'terminal' and terminalG(g, gi, gv))
      yield [['invisible_testSuccessG', g, gi, gv, s]]
    else
      yield [['invisible_testFailure', g, gi, s]]
    end
  end
end

# (:method (testGoalCommitmentRule ?rule ?g ?gi ?a ?c ?ci ?de ?cr)
#   ((goal ?g ?gi ?a) (commitment ?c ?ci ?de ?cr) (call = ?rule eqGSCP) (eqGSCP ?g ?gv ?c ?cv))
#   ((!!testRuleSuccess ?rule (?g ?gi ?gv ?c ?ci ?cv) ))
# )

def testGoalCommitmentRule_case0(rule, g, gi, a, c, ci, de, cr)
  # TODO eqGSCP may have multiple unifications for gv and cv
  gv = ''
  cv = ''
  if state(GOAL, g, gi, a) and state(COMMITMENT, c, ci, de, cr) and rule == 'eqGSCP' and eqGSCP(g, gv, c, cv)
    yield [['invisible_testRuleSuccess', rule, list(g, gi, gv, c, ci, cv)]]
  end
end