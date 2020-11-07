#=============================================
# Axioms for goals
# predicates on goals - null(g,gi,gv) suspendedG(g,gi,gv) aborted(g,gi,gv) dropped(g,gi,gv) satisfiedG(g,gi,gv)
#=============================================

# (:- (nullG ?g ?gi ?gv) (not (varG ?g ?gi ?gv) ))
def nullG(g, gi, gv)
  not state(VARG, g, gi, gv)
end

# (:- (inactiveG ?g ?gi ?gv) (and
#   (not (nullG ?g ?gi ?gv))
#   (not (f ?g ?gi ?gv))
#   (not (s ?g ?gi ?gv))
#   (not (terminalG ?g ?gi ?gv))
#   (not (suspendedG ?g ?gi ?gv))
#   (not (activeG ?g ?gi ?gv)))
# )

def inactiveG(g, gi, gv)
  not nullG(g, gi, gv) and
  not f(g, gi, gv) and
  not s(g, gi, gv) and
  not terminalG(g, gi, gv) and
  not state(SUSPENDEDG, g, gi, gv) and
  not activeG(g, gi, gv)
end

# Fix this
# (:- (activeG ?g ?gi ?gv) (and
#   (activatedG ?g ?gi ?gv)
#   (not (f ?g ?gi ?gv))
#   (not (satisfiedG ?g ?gi ?gv))
#   (not (terminalG ?g ?gi ?gv))
#   (not (suspendedG ?g ?gi ?gv))
# ))

def activeG(g, gi, gv)
  state(ACTIVATEDG, g, gi, gv) and
  not f(g, gi, gv) and
  not satisfiedG(g, gi, gv) and
  not terminalG(g, gi, gv) and
  not state(SUSPENDEDG, g, gi, gv)
end

# (:- (satisfiedG ?g ?gi ?gv) (and
#   (not (nullG ?g ?gi ?gv))
#   (not (terminalG ?g ?gi ?gv))
#   (pg ?g ?gi ?gv)
#   (s ?g ?gi ?gv)
#   (not (f ?g ?gi ?gv))
# ))

def satisfiedG(g, gi, gv)
  not nullG(g, gi, gv) and
  not terminalG(g, gi, gv) and
  pg(g, gi, gv) and
  s(g, gi, gv) and
  not f(g, gi, gv)
end

# ; (:- (suspended ?g ?gi ?gv) (and (not (nullG ?g ?gi ?gv)) (not (terminal ?g ?gi ?gv)) (suspended ?g ?gi ?gv) ))

# (:- (failedG ?g ?gi ?gv) (and (not (nullG ?g ?gi ?gv)) (f ?g ?gi ?gv) ))

def failedG(g, gi, gv)
  not nullG(g, gi, gv) and f(g, gi, gv)
end

# (:- (terminatedG ?g ?gi ?gv) (and (not (nullG ?g ?gi ?gv)) (or (dropped ?g ?gi ?gv) (aborted ?g ?gi ?gv)) ))

def terminatedG(g, gi, gv)
  not nullG(g, gi, gv) and (state(DROPPED, g, gi, gv) or state(ABORTED, g, gi, gv))
end

# A rule to ensure that once a goal enters a terminal state (e.g. dropped or aborted), it cannot return
# (:- (terminalG ?g ?gi ?gv) (and (goal ?g ?gi ?a) (or (dropped ?g ?gi ?gv) (aborted ?g ?gi ?gv) ) ))

def terminalG(g, gi, gv)
  @state[GOAL].any? {|terms| terms.size == 3 and terms[0] == g and terms[1] == gi} and (state(DROPPED, g, gi, gv) or state(ABORTED, g, gi, gv))
end