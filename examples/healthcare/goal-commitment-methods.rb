#==================================
# Methods on goals and commitments
# Practical Rules
#=================================

# PT: These methods need to relate  commitment's antecedent
# and consequent with goals success condition.
# If G = G(x, s, f), then C should be C(x, y, s, u) where u
# can be any condition, but "s" need to be the same. 
# I am not sure how to write it in this language.

# TODO (2013/01/04) Make sure that my current equality of ?cv and ?gv for the eqGSCP is correct
# (:method (entice ?g ?gi ?gv ?c ?ci ?cv ?d ?a)
#   (
#     (goal ?g ?gi ?d)
#     (activeG ?g ?gi ?gv)
#     (commitment ?c ?ci ?d ?a)
#     (null ?c ?ci ?cv)
#     (eqGSCP ?g ?gv ?c ?cv) ; In theory, this axiom will ensure that the S of G is true at the same time as the P of C
#   )
#   ((!create ?c ?ci ?d ?a ?cv))
# )

def entice_case0(g, gi, gv, c, ci, cv, d, a)
  if state('goal', g, gi, d) and activeG(g, gi, gv) and state('commitment', c, ci, d, a) and null(c, ci, cv) and eqGSCP(g, gv, c, cv)
    yield [['create', c, ci, d, a, cv]]
  end
end

# Suspends an offer from ?d to ?a
# (:method (suspendOffer ?g ?gi ?gv ?c ?ci ?cv ?d ?a)
#   ((goal ?g ?gi ?d) (suspendedG ?g ?gi ?gv) (commitment ?c ?ci ?d ?a) (active ?c ?ci ?cv))
#   ((!suspend ?c ?ci ?d ?a ?cv))
# )

def suspendOffer_case0(g, gi, gv, c, ci, cv, d, a)
  if state('goal', g, gi, d) and state('suspendedG', g, gi, gv) and state('commitment', c, ci, d, a) and active(c, ci, cv)
    yield [['suspend', c, ci, d, a, cv]]
  end
end

# Revives a commitment when a goal becomes active
# (:method (revive ?g ?gi ?gv ?c ?ci ?cv ?d ?a)
#   ((goal ?g ?gi ?d) (activeG ?g ?gi ?gv) (commitment ?c ?ci ?d ?a) (pending ?c ?ci ?cv))
#   ((!reactivate ?c ?ci ?d ?a ?cv))
# )

def revive_case0(g, gi, gv, c, ci, cv, d, a)
  if state('goal', g, gi, d) and activeG(g, gi, gv) and state('commitment', c, ci, d, a) and state('pending', c, ci, cv)
    yield [['reactivate', c, ci, d, a, cv]]
  end
end

# Withdraws a commitment when a goal has failed or terminated
# (:method (withdrawOffer ?g ?gi ?gv ?c ?ci ?cv ?d ?a)
#   ((goal ?g ?gi ?d) (or (failedG ?g ?gi ?gv) (terminatedG ?g ?gi ?gv)) (commitment ?c ?ci ?d ?a) (active ?c ?ci ?cv))
#   ((!cancel ?c ?ci ?d ?a ?cv))
# )

def withdrawOffer_case0(g, gi, gv, c, ci, cv, d, a)
  if state('goal', g, gi, d) and (failedG(g, gi, gv) or terminatedG(g, gi, gv)) and state('commitment', c, ci, d, a) and active(c, ci, cv)
    yield [['cancel', c, ci, d, a, cv]]
  end
end

# Revives a commitment to withdraw it?
# (:method (reviveToWithdraw ?g ?gi ?gv ?c ?ci ?cv ?d ?a)
#   ((goal ?g ?gi ?d) (or (failedG ?g ?gi ?gv) (terminatedG ?g ?gi ?gv)) (commitment ?c ?ci ?d ?a) (pending ?c ?ci ?cv))
#   ((!reactivate ?c ?ci ?d ?a ?cv))
# )

def reviveToWithdraw_case0(g, gi, gv, c, ci, cv, d, a)
  if state('goal', g, gi, d) and (failedG(g, gi, gv) or terminatedG(g, gi, gv)) and state('commitment', c, ci, d, a) and state('pending', c, ci, cv)
    yield [['reactivate', c, ci, d, a, cv]]
  end
end

# Axioms Added for readbility
# (:- (negotiable ?g ?gi ?gv ?c ?ci ?cv) (and (or (activeG ?g ?gi ?gv) (suspendedG ?g ?gi ?gv) ) (or (expired ?c ?ci ?cv) (terminated ?c ?ci ?cv)) ) )

def negotiable(g, gi, gv, c, ci, cv)
  (activeG(g, gi, gv) or state('suspendedG', g, gi, gv)) and (state('expired', c, ci, cv) or terminated(c, ci, cv))
end

# (:method (negotiate ?g ?gi ?gv ?c1 ?ci1 ?cv1 ?c2 ?ci2 ?cv2 ?d ?a1 ?a2)
#   ;Replaced by this expression TODO check what we are using a1 for
#   ((goal ?g ?gi ?d) (commitment ?c1 ?ci1 ?d ?a2) (commitment ?c2 ?ci2 ?d ?a2) (null ?c2 ?ci2 ?cv2) (negotiable ?g ?gi ?gv ?c1 ?ci1 ?cv2))
#   ((!create ?c2 ?ci2 ?d ?a2 ?ci2)) ;check that we really want ?ci2 as the last parameter instead of cv2
# )

def negotiate_case0(g, gi, gv, c1, ci1, cv1, c2, ci2, cv2, d, a1, a2)
  if state('goal', g, gi, d) and state('commitment', c1, ci1, d, a2) and state('commitment', c2, ci2, d, a2) and null(c2, ci2, cv2) and negotiable(g, gi, gv, c1, ci1, cv2)
    yield [['create', c2, ci2, d, a2, ci2]]
  end
end

# (:method (abandonEndGoal ?g ?gi ?gv ?c ?ci ?cv ?d ?a)
#   ; Combinations of (A v U) and (E v T): AE AT UE UT
#   ((goal ?g ?gi ?d) (or (activeG ?g ?gi ?gv) (suspendedG ?g ?gi ?gv)) (commitment ?c ?ci ?d ?a) (or (expired ?c ?ci ?cv) (terminated ?c ?ci ?cv)))
#   ((!drop ?g ?gi ?d ?gv))
# )

def abandonEndGoal_case0(g, gi, gv, c, ci, cv, d, a)
  if state('goal', g, gi, d) and (activeG(g, gi, gv) or state('suspendedG', g, gi, gv)) and state('commitment', c, ci, d, a) and (state('expired', c, ci, cv) or terminated(c, ci, cv))
    yield [['drop', g, gi, d, gv]]
  end
end

# Deliver and Deliver' are encoded in a single method
# (:method (deliver ?g ?gi ?gv ?c ?ci ?cv ?d ?a)
#   ; Deliver (debtor delivers)
#   ((goal ?g ?gi ?d) (nullG ?g ?gi ?gv) (commitment ?c ?ci ?d ?a) (detached ?c ?ci ?cv))
#   ( (!consider ?g ?gi ?d ?gv) (!activate ?g ?gi ?d ?gv) )
#   ; Deliver' (debtor delivers)
#   ((goal ?g ?gi ?d) (inactiveG ?g ?gi ?gv) (commitment ?c ?ci ?d ?a) (detached ?c ?ci ?cv))
#   ((!activate ?g ?gi ?d ?gv))
# )

def deliver_case0(g, gi, gv, c, ci, cv, d, a)
  if state('goal', g, gi, d) and nullG(g, gi, gv) and state('commitment', c, ci, d, a) and detached(c, ci, cv)
    yield [
      ['consider', g, gi, d, gv],
      ['activate', g, gi, d, gv]
    ]
  end
end

def deliver_case1(g, gi, gv, c, ci, cv, d, a)
  if state('goal', g, gi, d) and inactiveG(g, gi, gv) and state('commitment', c, ci, d, a) and detached(c, ci, cv)
    yield [['activate', g, gi, d, gv]]
  end
end

# (:method (detach ?g ?gi ?gv ?c ?ci ?cv ?d ?a)
#   ; Detach (creditor detaches)
#   ((goal ?g ?gi ?a) (nullG ?g ?gi ?gv) (commitment ?c ?ci ?d ?a) (conditional ?c ?ci ?cv))
#   ((!consider ?g ?gi ?a ?gv) (!activate ?g ?gi ?a ?gv))
#   ; Detach' (creditor detaches)
#   ((goal ?g ?gi ?a) (inactiveG ?g ?gi ?gv) (commitment ?c ?ci ?d ?a) (conditional ?c ?ci ?cv))
#   ((!activate ?g ?gi ?a ?gv))
# )

def detach_case0(g, gi, gv, c, ci, cv, d, a)
  if state('goal', g, gi, a) and nullG(g, gi, gv) and state('commitment', c, ci, d, a) and conditional(c, ci, cv)
    yield [['consider', g, gi, a, gv], ['activate', g, gi, a, gv]]
  end
end

def detach_case1(g, gi, gv, c, ci, cv, d, a)
  if state('goal', g, gi, a) and inactiveG(g, gi, gv) and state('commitment', c, ci, d, a) and conditional(c, ci, cv)
    yield [['activate', g, gi, a, gv]]
  end
end

# (:method (backBurner ?g ?gi ?gv ?c ?ci ?cv ?d ?a)
#   ((goal ?g ?gi ?d) (activeG ?g ?gi ?gv) (commitment ?c ?ci ?d ?a) (pending ?c ?ci ?cv))
#   ((!suspendG ?g ?gi ?d ?gv))
# )

def backBurner_case0(g, gi, gv, c, ci, cv, d, a)
  if state('goal', g, gi, d) and activeG(g, gi, gv) and state('commitment', c, ci, d, a) and state('pending', c, ci, cv)
    yield [['suspendG', g, gi, d, gv]]
  end
end

# (:method (frontBurner ?g ?gi ?gv ?c ?ci ?cv ?d ?a)
#   ((goal ?g ?gi ?d) (suspendedG ?g ?gi ?gv) (commitment ?c ?ci ?d ?a) (detached ?c ?ci ?cv))
#   ((!reactivateG ?g ?gi ?d ?gv))
# )

def frontBurner_case0(g, gi, gv, c, ci, cv, d, a)
  if state('goal', g, gi, d) and state('suspendedG', g, gi, gv) and state('commitment', c, ci, d, a) and detached(c, ci, cv)
    yield [['reactivateG', g, gi, d, gv]]
  end
end

# (:method (abandonMeansGoal ?g ?gi ?gv ?c ?ci ?cv ?d ?a)
#   ((goal ?g ?gi ?d) (or (activeG ?g ?gi ?gv) (suspendedG ?g ?gi ?gv)) (commitment ?c ?ci ?d ?a)
#                     (or (expired ?c ?ci ?cv) (terminated ?c ?ci ?cv)) )
#   ((!drop ?g ?gi ?d ?gv))
# )

def abandonMeansGoal_case0(g, gi, gv, c, ci, cv, d, a)
  if state('goal', g, gi, d) and (activeG(g, gi, gv) or state('suspendedG', g, gi, gv)) and state('commitment', c, ci, d, a) and (state('expired', c, ci, cv) or terminated(c, ci, cv))
    yield [['drop', g, gi, d, gv]]
  end
end

# (:method (persist ?g ?gi ?gv ?c ?ci ?cv ?g2 ?gi2 ?gv2 ?d ?a)
#   ((goal ?g ?gi ?d) (or (terminatedG ?g ?gi ?gv) (failedG ?g ?gi ?gv)) (commitment ?c ?ci ?d ?a) (detached ?c ?ci ?cv) (goal ?g2 ?gi2 ?d) (nullG ?g2 ?gi2 ?gv2))
#   ((!consider ?g2 ?gi2 ?d ?gv2) (!activate ?g2 ?gi2 ?d ?gv2))
# )

def persist_case0(g, gi, gv, c, ci, cv, g2, gi2, gv2, d, a)
  if state('goal', g, gi, d) and (terminatedG(g, gi, gv) or failedG(g, gi, gv)) and state('commitment', c, ci, d, a) and detached(c, ci, cv) and state('goal', g2, gi2, d) and nullG(g2, gi2, gv2)
    yield [
      ['consider', g2, gi2, d, gv2],
      ['activate', g2, gi2, d, gv2]
    ]
  end
end

# (:method (giveUp ?g ?gi ?gv ?c ?ci ?cv ?d ?a)
#   ((goal ?g ?gi ?d) (or (terminatedG ?g ?gi ?gv) (failed ?g ?gi ?gv)) (commitment ?c ?ci ?d ?a) (detached ?c ?ci ?cv))
#   ((!cancel ?c ?ci ?d ?a ?cv))
# )

def giveUp_case0(g, gi, gv, c, ci, cv, d, a)
  if state('goal', g, gi, d) and (terminatedG(g, gi, gv) or state('failed', g, gi, gv)) and state('commitment', c, ci, d, a) and detached(c, ci, cv)
    yield [['cancel', c, ci, d, a, cv]]
  end
end