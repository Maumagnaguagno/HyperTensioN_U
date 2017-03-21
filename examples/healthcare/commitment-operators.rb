#======================
# Commitment operators
#======================

# (:operator (!!testSuccess ?c ?ci ?cv ?state)
#   (commitment ?c ?ci ?de ?cr)
#   ()
#   ()
#   0
# )

def invisible_testSuccess(c, ci, cv, state)
  @state['commitment'].any? {|terms| terms.size == 4 and terms[0] == c and terms[1] == ci}
end

# (:operator (!!testFailure ?cg ?state)
#   ()
#   ()
#   ()
#   0
# )

def invisible_testFailure(cg, state)
  true
end

# (:operator (!create ?c ?ci ?de ?cr ?cv)
#   (
#     (commitment ?c ?ci ?de ?cr)
#     (null ?c ?ci ?cv)
#   )
#   ()
#   ((var ?c ?ci ?cv))
#   0
# )

def create(c, ci, de, cr, cv)
  if state('commitment', c, ci, de, cr) and null(c, ci, cv)
    apply([['var', c, ci, cv]], [])
  end
end

# (:operator (!suspend ?c ?ci ?de ?cr ?cv)
#   (
#     (commitment ?c ?ci ?de ?cr)
#     (active ?c ?ci ?cv)
#   )
#   ()
#   ((pending ?c ?ci ?cv))
#   1
# )

def suspend(c, ci, de, cr, cv)
  if state('commitment', c, ci, de, cr) and active(c, ci, cv)
    apply([['pending', c, ci, cv]], [])
  end
end

# FM: In PDDL it was revive, but in the papers it's called reactivate
# PT: Without checking for p in the pre-condition, these operators will not work correctly
# FM (26/12/2012): Which ones? Just reactivate?  <------ TODO: Check this Pankaj

# (:operator (!reactivate ?c ?ci ?de ?cr ?cv)
#   (
#     (commitment ?c ?ci ?de ?cr)
#     (pending ?c ?ci ?cv)
#   )
#   ((pending ?c ?ci ?cv))
#   ()
#   1
# )

def reactivate(c, ci, de, cr, cv)
  if state('commitment', c, ci, de, cr) and state('pending', c, ci, cv)
    apply([], [['pending', c, ci, cv]])
  end
end

# (:operator (!expire ?c ?ci ?de ?cr ?cv)
#   (
#     (commitment ?c ?ci ?de ?cr)
#     (conditional ?c ?ci ?cv)
#     (activetimeout ?c ?ci ?cv)
#   )
#   ()
#   ((expired ?c ?ci ?cv))
#   5
# )

def expire(c, ci, de, cr, cv)
  if state('commitment', c, ci, de, cr) and conditional(c, ci, cv) and activetimeout(c, ci, cv)
    apply([['expired', c, ci, cv]], [])
  end
end

# (:operator (!timeoutviolate ?c ?ci ?de ?cr ?cv)
#   (
#     (commitment ?c ?ci ?de ?cr)
#     (detached ?c ?ci ?cv)
#     (detachedtimeout ?c ?ci ?cv)
#   )
#   ((detached ?c ?ci ?cv))
#   ((violated ?c ?ci ?cv))
#   5
# )

def timeoutviolate(c, ci, de, cr, cv)
  if state('commitment', c, ci, de, cr) and detached(c, ci, cv) and detachedtimeout(c, ci, cv)
    apply([['violated', c, ci, cv]], [['detached', c, ci, cv]])
  end
end

# (:operator (!cancel ?c ?ci ?de ?cr ?cv)
#   (
#     (commitment ?c ?ci ?de ?cr)
#     (active ?c ?ci ?cv)
#   )
#   ()
#   ((cancelled ?c ?ci ?cv))
#   10
# )

def cancel(c, ci, de, cr, cv)
  if state('commitment', c, ci, de, cr) and active(c, ci, cv)
    apply([['cancelled', c, ci, cv]], [])
  end
end

# (:operator (!release ?c ?ci ?de ?cr ?cv)
#   (
#     (commitment ?c ?ci ?de ?cr)
#     (active ?c ?ci ?cv)
#   )
#   ()
#   ((released ?c ?ci ?cv))
#   1
# )

def release(c, ci, de, cr, cv)
  if state('commitment', c, ci, de, cr) and active(c, ci, cv)
    apply([['released', c, ci, cv]], [])
  end
end