#=============================================
# Axioms for commitments
# predicates on commitments
# null(c,ci,cv) cancelled(c,ci,cv) released(c,ci,cv)
# pending(c,ci,cv) satisfied(c,ci,cv)
#=============================================

# (:- (null ?c ?ci ?cv) (not (var ?c ?ci ?cv)) )
def null(c, ci, cv)
  not state('var', c, ci, cv)
end

# (:- (conditional ?c ?ci ?cv) (and (active ?c ?ci ?cv) (not (p ?c ?ci ?cv)) ) )
def conditional(c, ci, cv)
  active(c, ci, cv) and not state('p', c, ci, cv)
end

# (:- (detached ?c ?ci ?cv) (and (active ?c ?ci ?cv) (p ?c ?ci ?cv) ) )
def detached(c, ci, cv)
  active(c, ci, cv) and state('p', c, ci, cv)
end

# A conditional commitment is active
# (:- (active ?c ?ci ?cv) (and
#   (var ?c ?ci ?cv) ;(not (null ?c ?ci ?cv))
#   (not (terminal ?c ?ci ?cv))
#   (not (pending ?c ?ci ?cv))
#   (not (satisfied ?c ?ci ?cv))
# ) )
def active(c, ci, cv)
  state('var', c, ci, cv) and
  not terminal(c, ci, cv) and
  not state('pending', c, ci, cv) and
  not satisfied(c, ci, cv)
end

# (:- (terminated ?c ?ci ?cv) (or (and (not (p ?c ?ci ?cv)) (cancelled ?c ?ci ?cv)) (released ?c ?ci ?cv) ) )
def terminated(c, ci, cv)
  ( (not state('p', c, ci, cv)) and state('cancelled', c, ci, cv) ) or state('released', c, ci, cv)
end

# ;(:- (violated ?c ?ci ?cv) (or (and (p ?c ?ci ?cv) (cancelled ?c ?ci ?cv)) (and (not (p ?c ?ci ?cv)) ) ) ) ; Previous formalization with a mistaken disjunction, detected by Pankaj
# (:- (violated ?c ?ci ?cv) (and (p ?c ?ci ?cv) (cancelled ?c ?ci ?cv)) )
def violated(c, ci, cv)
  state('p', c, ci, cv) and state('cancelled', c, ci, cv)
end

# (:- (satisfied ?c ?ci ?cv) (and (not (null ?c ?ci ?cv)) (not (terminal ?c ?ci ?cv)) (q ?c ?ci ?cv)) )
def satisfied(c, ci, cv)
  (not null(c, ci, cv)) and (not terminal(c, ci, cv)) and q(c, ci, cv)
end

# ;(:- (expired ?c ?ci ?cv) (and (not (null ?c ?ci ?cv)) (not (p ?c ?ci ?cv)) ) )

# A rule to enumerate that certain states are terimnal
# (:- (terminal ?c ?ci ?cv) (and (commitment ?c ?ci ?de ?cr) (or (cancelled ?c ?ci ?cv) (released ?c ?ci ?cv) (expired ?c ?ci ?cv))) )
def terminal(c, ci, cv)
  # Free variables de and cr requires special comparison
  @state['commitment'].any? {|terms| terms[0] == c and terms[1] == ci and terms[2] == cv} and
  (state('cancelled', c, ci, cv) or state('released', c, ci, cv) or state('expired', c, ci, cv))
end