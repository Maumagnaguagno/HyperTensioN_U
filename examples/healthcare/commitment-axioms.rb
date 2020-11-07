#=============================================
# Axioms for commitments
# predicates on commitments
# null(c,ci,cv) cancelled(c,ci,cv) released(c,ci,cv)
# pending(c,ci,cv) satisfied(c,ci,cv)
#=============================================

# (:- (null ?c ?ci ?cv) (not (var ?c ?ci ?cv) ))
def null(c, ci, cv)
  cv.empty? ? @state[VAR].none? {|terms| terms.size == 3 and terms[0] == c and terms[1] == ci and cv.replace(terms[2])} : !state(VAR, c, ci, cv)
end

# (:- (conditional ?c ?ci ?cv) (and (active ?c ?ci ?cv) (not (p ?c ?ci ?cv)) ))
def conditional(c, ci, cv)
  active(c, ci, cv) and not p(c, ci, cv)
end

# (:- (detached ?c ?ci ?cv) (and (active ?c ?ci ?cv) (p ?c ?ci ?cv) ))
def detached(c, ci, cv)
  active(c, ci, cv) and p(c, ci, cv)
end

# A conditional commitment is active
# (:- (active ?c ?ci ?cv) (and
#   (var ?c ?ci ?cv) ;(not (null ?c ?ci ?cv))
#   (not (terminal ?c ?ci ?cv))
#   (not (pending ?c ?ci ?cv))
#   (not (satisfied ?c ?ci ?cv))
# ))
def active(c, ci, cv)
  state(VAR, c, ci, cv) and
  not terminal(c, ci, cv) and
  not state(PENDING, c, ci, cv) and
  not satisfied(c, ci, cv)
end

# (:- (terminated ?c ?ci ?cv) (or (and (not (p ?c ?ci ?cv)) (cancelled ?c ?ci ?cv)) (released ?c ?ci ?cv) ))
def terminated(c, ci, cv)
  (not p(c, ci, cv) and state(CANCELLED, c, ci, cv)) or state(RELEASED, c, ci, cv)
end

# ;(:- (violated ?c ?ci ?cv) (or (and (p ?c ?ci ?cv) (cancelled ?c ?ci ?cv)) (and (not (p ?c ?ci ?cv)) ) ) ) ; Previous formalization with a mistaken disjunction, detected by Pankaj
# (:- (violated ?c ?ci ?cv) (and (p ?c ?ci ?cv) (cancelled ?c ?ci ?cv) ))
def violated(c, ci, cv)
  p(c, ci, cv) and state(CANCELLED, c, ci, cv)
end

# (:- (satisfied ?c ?ci ?cv) (and (not (null ?c ?ci ?cv)) (not (terminal ?c ?ci ?cv)) (q ?c ?ci ?cv) ))
def satisfied(c, ci, cv)
  not null(c, ci, cv) and not terminal(c, ci, cv) and q(c, ci, cv)
end

# ;(:- (expired ?c ?ci ?cv) (and (not (null ?c ?ci ?cv)) (not (p ?c ?ci ?cv)) ) )

# A rule to enumerate that certain states are terimnal
# (:- (terminal ?c ?ci ?cv) (and (commitment ?c ?ci ?de ?cr) (or (cancelled ?c ?ci ?cv) (released ?c ?ci ?cv) (expired ?c ?ci ?cv)) ))
def terminal(c, ci, cv)
  # Free variables de and cr requires special comparison
  @state[COMMITMENT].any? {|terms| terms.size == 4 and terms[0] == c and terms[1] == ci} and
  (state(CANCELLED, c, ci, cv) or state(RELEASED, c, ci, cv) or state(EXPIRED, c, ci, cv))
end