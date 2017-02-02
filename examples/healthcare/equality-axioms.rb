#==========================================================
# Equalities between conditions on commitments and on goals
#==========================================================

# ; True if the success condition of ?g matches the antecedent of ?c 
# ;(?gv and ?cv will unify with the specific instance of ?g and ?c that match this)
# (:- (eqGSCP ?g ?gv ?c ?cv) (and (imply (s ?g ?gi ?gv) (p ?c ?ci ?cv)) (imply (p ?c ?ci ?cv) (s ?g ?gi ?gv)) ) ) ; Basically a logical equivalence <->

def eqGSCP(g, gv, c, cv)
  s_si_unified = [G1, G2, G3, G4, G5].any? {|gi| s(g, gi, gv)}
  p_ci_unified = [C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12].any? {|ci| p(c, ci, cv)}
  s_si_unified == p_ci_unified
end

#     ;TODO make sure that the variables ?gv and ?cv get instantiated
# ; True of the success condition of ?g matches the consequent of ?c
# (:- (eqGSCQ ?g ?gv ?c ?cv) (and (imply (s ?g ?gi ?gv) (q ?c ?ci ?cv)) (imply (q ?c ?ci ?cv) (s ?g ?gi ?gv)) ) ) ; Basically a logical equivalence <->

def eqGSCQ(g, gv, c, cv)
  # TODO eqGSCQ
  raise 'eqGSCQ is not implemented'
end

# ; True of the the antecedent of commitment ?c1 matches the consequent of commitment ?c2 (so they are reciprocal)
# (:- (eqCPCQ ?c1 ?cv1 ?c2 ?cv2) (and (imply (p ?c1 ?ci1 ?cv1) (q ?c2 ?ci2 ?cv2)) (imply (q ?c2 ?ci2 ?cv2) (p ?c1 ?ci1 ?cv1)) ) ) ; Basically a logical equivalence <->

def eqCPCQ(c1, cv1, c2, cv2)
  # TODO eqCPCQ
  raise 'eqCPCQ is not implemented'
end