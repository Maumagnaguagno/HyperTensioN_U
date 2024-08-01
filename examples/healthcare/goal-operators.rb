#=============================================
# Goal operators
#=============================================

# (:operator (!!testSuccessG ?g ?gi ?gv ?state)
#   (goal ?g ?gi ?a)
#   ()
#   ()
#   0
# )

def invisible_testSuccessG(g, gi, gv, state)
  @state[GOAL].any? {|terms| terms.size == 3 and terms[0] == g and terms[1] == gi}
end

# Regular transitions
# (:operator (!consider ?g ?gi ?a ?gv)
#   (
#     (goal ?g ?gi ?a)
#     (nullG ?g ?gi ?gv)
#     (pg ?g ?gi ?gv)
#   )
#   ()
#   ((varG ?g ?gi ?gv))
#   1
# )

def consider(g, gi, a, gv)
  if state(GOAL, g, gi, a) and nullG(g, gi, gv) and pg(g, gi, gv)
    apply([[VARG, g, gi, gv]], [])
  end
end

# (:operator (!activate ?g ?gi ?a ?gv)
#   (
#     (goal ?g ?gi ?a)
#     (inactiveG ?g ?gi ?gv)
#   )
#   ()
#   ((activatedG ?g ?gi ?gv))
#   1
# )

def activate(g, gi, a, gv)
  if state(GOAL, g, gi, a) and inactiveG(g, gi, gv)
    apply([[ACTIVATEDG, g, gi, gv]], [])
  end
end

# (:operator (!suspendG ?g ?gi ?a ?gv)
#   (
#     (goal ?g ?gi ?a)
#     (not (terminalG ?g ?gi ?gv))
#     (not (nullG ?g ?gi ?gv))
#   )
#   ((activatedG ?g ?gi ?gv))
#   ((suspendedG ?g ?gi ?gv))
#   1
# )

def suspendG(g, gi, a, gv)
  if state(GOAL, g, gi, a) and not terminalG(g, gi, gv) and not nullG(g, gi, gv)
    apply([[SUSPENDEDG, g, gi, gv]], [[ACTIVATEDG, g, gi, gv]])
  end
end

# (:operator (!reconsider ?g ?gi ?a ?gv)
#   (
#     (goal ?g ?gi ?a)
#     (suspendedG ?g ?gi ?gv)
#     (not (terminalG ?g ?gi ?gv))
#     ;(not (pg ?g ?gi ?gv))
#     (not (nullG ?g ?gi ?gv))
#   )
#   ((suspendedG ?g ?gi ?gv))
#   ()
#   1
# )

def reconsider(g, gi, a, gv)
  if state(GOAL, g, gi, a) and state(SUSPENDEDG, g, gi, gv) and not terminalG(g, gi, gv) and not nullG(g, gi, gv)
    apply([[DROPPED, g, gi, gv]], [])
  end
end

# (:operator (!reactivateG ?g ?gi ?a ?gv)
#   (
#     (goal ?g ?gi ?a)
#     (suspendedG ?g ?gi ?gv)
#     (not (terminalG ?g ?gi ?gv))
#     ;(pg ?g ?gi ?gv)
#     (not (nullG ?g ?gi ?gv))
#   )
#   ((suspendedG ?g ?gi ?gv))
#   ((activatedG ?g ?gi ?gv))
#   1
# )

def reactivateG(g, gi, a, gv)
  if state(GOAL, g, gi, a) and state(SUSPENDEDG, g, gi, gv) and not terminalG(g, gi, gv) and not nullG(g, gi, gv)
    apply([[ACTIVATEDG, g, gi, gv]], [[SUSPENDEDG, g, gi, gv]])
  end
end

# (:operator (!drop ?g ?gi ?a ?gv)
#   (
#     (goal ?g ?gi ?a)
#     (not (terminalG ?g ?gi ?gv))
#     (not (nullG ?g ?gi ?gv))
#   )
#   ()
#   ((dropped ?g ?gi ?gv))
#   1
# )

def drop(g, gi, a, gv)
  if state(GOAL, g, gi, a) and not terminalG(g, gi, gv) and not nullG(g, gi, gv)
    apply([[DROPPED, g, gi, gv]], [])
  end
end

# (:operator (!abort ?g ?gi ?a ?gv)
#   (
#     (goal ?g ?gi ?a)
#     (not (terminalG ?g ?gi ?gv))
#     (not (nullG ?g ?gi ?gv))
#   )
#   ()
#   ((aborted ?g ?gi ?gv))
#   1
# )

def abort_(g, gi, a, gv)
  if state(GOAL, g, gi, a) and not terminalG(g, gi, gv) and not nullG(g, gi, gv)
    apply([[ABORTED, g, gi, gv]], [])
  end
end

# ; Fail does not depend on the agent to happen
# ; (:operator (!fail ?g ?gi ?a ?gv)
# ;   (
# ;     (goal ?g ?gi ?a)
# ;     (not (nullG ?g ?gi ?gv))
# ;     (f ?g ?gi ?gv)
# ;   )
# ;   ()
# ;   ((failed ?g ?gi ?gv))
# ;   1
# ; )