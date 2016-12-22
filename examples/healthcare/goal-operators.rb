#=============================================
# Goal operators
#=============================================

# (:operator (!!testSuccessG ?g ?gi ?gv ?state)
#   ((goal ?g ?gi ?a))
#   ()
#   ()
#   0
# )

def invisible_testSuccessG(g, gi, gv, state)
  @state['goal'].any? {|terms| terms[0] == g and terms[1] == gi}
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
  if state('goal', g, gi, a) and nullG(g, gi, gv) and state('pg', g, gi, gv)
    apply(['varG', g, gi, gv], [])
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
  if state('goal', g, gi, a) and inactiveG(g, gi, gv)
    apply(['activatedG', g, gi, gv], [])
  end
end

# (:operator (!suspendG ?gi ?a ?gv)
#   (
#     (goal ?g ?gi ?a)
#     (not (terminalG ?g ?gi ?gv))
#     (not (nullG ?g ?gi ?gv))
#   )
#   ((activatedG ?g ?gi ?gv))
#   ((suspendedG ?g ?gi ?gv))
#   1
# )

def suspendG(gi, a, gv)
  # TODO g is a free variable
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
  if state('goal', g, gi, a) and state('suspendedG', g, gi, gv) and not terminalG(g, gi, gv) and not nullG(g, gi, gv)
    apply(['dropped', g, gi, gv], [])
  end
end

# (:operator (!reactivateG ?gi ?a ?gv)
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

def reactivateG(gi, a, gv)
  # TODO g is a free variable
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
  if state('goal', g, gi, a) and not terminalG(g, gi, gv) and not nullG(g, gi, gv)
    apply(['dropped', g, gi, gv], [])
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

def abort(g, gi, a, gv)
  if state('goal', g, gi, a) and not terminalG(g, gi, gv) and not nullG(g, gi, gv)
    apply(['aborted', g, gi, gv], [])
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