# Domain specific axioms
# C1(PHYSICIAN, PATIENT, diagnosisRequested ^ -vio(C2) ^ -vio(C3), diagnosisProvided)
# C2(PATIENT, PHYSICIAN, iAppointmentRequested, iAppointmentKept)
# C3(PATIENT, PHYSICIAN, bAppointmentRequested, bAppointmentKept)
# C4(RADIOLOGIST, PHYSICIAN, biopsyRequested ^ bAppointmentKept, radPathResultsReported)
# C5(RADIOLOGIST, PHYSICIAN, imagingRequested ^ iAppointmentKept, imagingResultsReported)
# C6(PATHOLOGIST, RADIOLOGIST, pathologyRequested ^ tissueProvided, pathResultsReported)
# C7(PATHOLOGIST, HOSPITAL, patientHasCancer, patientReportedToRegistrar)
# C8(REGISTRAR, HOSPITAL, patientReportedToRegistrar, addPatientToCancerRegistry)
# C9(HOSPITAL, PHYSICIAN, vio(C5) ^ escalate, create(C5') ^ create(D2')) - Does not work because it depends D5
#; (:- (q ?c C9 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (create ?C5) (create ?D2)) ) )
# C10(TUMORBOARD, RADIOLOGIST, radRequestsAssessment, TBAgreesPath _ TBDisagreesPath)
# C11(TUMORBOARD, PHYSICIAN, phyRequestsAssessment, TBAgreesRad _ TBDisagreesRad)
# C12(TUMORBOARD, PATIENT, patRequestsAssessment, TBAgreesPCP _ TBDisagreesPCP)

def p(c, parameter1, t)
  @state['commitment'].any? {|cterms|
    if cterms.size == 4 and cterms[0] == c and state('var', c, cterms[1], t)
      d = cterms[2]
      a = cterms[3]
      case parameter1
      when C1 # (:- (p ?c C1 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (diagnosisRequested ?a ?d) (not (violated ?c C2 (?t))) (not (violated ?c C3 (?t))))))
        state('diagnosisRequested', a, d) and not violated(c, C2, t) and not violated(c, C3, t)
      when C2 # (:- (p ?c C2 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (iAppointmentRequested ?d ?radiologist))))
        @state['iAppointmentRequested'].any? {|terms| terms.size == 2 and terms[0] == d}
      when C3 # (:- (p ?c C3 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (bAppointmentRequested ?d ?pathologist))))
        @state['bAppointmentRequested'].any? {|terms| terms.size == 2 and terms[0] == d}
      when C4 # (:- (p ?c C4 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (biopsyRequested ?a ?patient) (bAppointmentKept ?patient ?a))))
        @state['biopsyRequested'].any? {|terms| terms.size == 2 and terms[0] == a and state('bAppointmentKept', terms[1], a)}
      when C5 # (:- (p ?c C5 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (imagingRequested ?a ?patient) (iAppointmentKept ?patient ?a))))
        @state['imagingRequested'].any? {|terms| terms.size == 2 and terms[0] == a and state('iAppointmentKept', terms[1], a)}
      when C6 # (:- (p ?c C6 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (pathologyRequested ?physician ?d ?patient) (tissueProvided ?patient))))
        @state['pathologyRequested'].any? {|terms| terms.size == 3 and terms[1] == d and state('tissueProvided', terms[2])}
      when C7 # (:- (p ?c C7 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (patientHasCancer ?patient))))
        @state['patientHasCancer'].any? {|terms| terms.size == 1}
      when C8 # (:- (p ?c C8 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (patientReportedToRegistrar ?patient ?d))))
        @state['patientReportedToRegistrar'].any? {|terms| terms[1] == d}
      when C9 # (:- (p ?c C9 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (violated ?c C5 ?t) (escalate))))
        violated(c, C5, t) and state('escalate')
      when C10 # (:- (p ?c C10 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (radRequestsAssessment))))
        state('radRequestsAssessment')
      when C11 # (:- (p ?c C11 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (phyRequestsAssessment))))
        state('phyRequestsAssessment')
      when C12 # (:- (p ?c C12 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (patRequestsAssessment))))
        state('patRequestsAssessment')
      end
    end
  }
end

def q(c, parameter1, t)
  @state['commitment'].any? {|cterms|
    if cterms.size == 4 and cterms[0] == c and state('var', c, cterms[1], t)
      d = cterms[2]
      a = cterms[3]
      case parameter1
      when C1 # (:- (q ?c C1 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (diagnosisProvided ?d ?a))))
        @state['diagnosisProvided'].any? {|terms| terms.size == 2 and terms[0] == d and terms[1] == a}
      when C2 # (:- (q ?c C2 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (iAppointmentKept ?d ?radiologist))))
        @state['iAppointmentKept'].any? {|terms| terms.size == 2 and terms[0] == d}
      when C3 # (:- (q ?c C3 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (bAppointmentKept ?d ?pathologist))))
        @state['bAppointmentKept'].any? {|terms| terms.size == 2 and terms[0] == d}
      when C4 # (:- (q ?c C4 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (radPathResultsReported ?d ?a ?patient))))
        @state['radPathResultsReported'].any? {|terms| terms.size == 3 and terms[0] == d and terms[1] == a}
      when C5 # (:- (q ?c C5 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (imagingResultsReported ?d ?a ?patient))))
        @state['imagingResultsReported'].any? {|terms| terms.size == 3 and terms[0] == d and terms[1] == a}
      when C6 # (:- (q ?c C6 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (pathResultsReported ?a ?physician ?patient))))
        @state['pathResultsReported'].any? {|terms| terms.size == 3 and terms[0] == a}
      when C7 # (:- (q ?c C7 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (patientReportedToRegistrar ?patient ?registrar))))
        @state['patientReportedToRegistrar'].any? {|terms| terms.size == 2}
      when C8 # (:- (q ?c C8 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (inRegistry ?patient))))
        @state['inRegistry'].any? {|terms| terms.size == 1}
      when C9 # (:- (q ?c C9 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (not (null ?c C5 ?ci)) (not (null ?c D5 ?ci)))))
        not null(c, C5, ci) and not null(c, 'D5', ci)
      when C10 # (:- (q ?c C10 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (or (TBAgreesPath) (TBDisagreesPath))))
        state('TBAgreesPath') or state('TBDisagreesPath')
      when C11 # (:- (q ?c C11 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (or (TBAgreesRad) (TBDisagreesRad))))
        state('TBAgreesRad') or state('TBDisagreesRad')
      when C12 # (:- (q ?c C12 (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (or (TBAgreesPCP) (TBDisagreesPCP))))
        state('TBAgreesPCP') or state('TBDisagreesPCP')
      end
    end
  }
end

# G1 = G(physician, diagnosisRequested, - diagnosisRequested)
# G2 = G(patient, diagnosisProvided, - diagnosisProvided)
# G3 = G(radiologist, biopsyRequested, - biopsyRequested)
# G4 = G(radiologist, imagingRequested, - imagingRequested)
# G5 = G(pathologist, pathologyRequested, - pathologyRequested)

# (:- (pg ?g G1 (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg ?g G2 (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg ?g G3 (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg ?g G4 (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg ?g G5 (?t)) (and (goal ?g ?gi ?a) ) )

def pg(g, gn, t)
  if gn == G1 or gn == G2 or gn == G3 or gn == G4 or gn == G5
    @state['goal'].any? {|terms| terms.size == 3 and terms[0] == g}
  end
end

# (:- (s ?g G1 (?t)) (and (goal ?g ?gi ?a) (var ?g ?gi (?t)) (diagnosisRequested ?patient ?physician) ) )
# (:- (s ?g G2 (?t)) (and (goal ?g ?gi ?a) (var ?g ?gi (?t)) (diagnosisProvided ?physician ?patient) ) )
# (:- (s ?g G3 (?t)) (and (goal ?g ?gi ?a) (var ?g ?gi (?t)) (biopsyRequested ?physician ?patient) ) )
# (:- (s ?g G4 (?t)) (and (goal ?g ?gi ?a) (var ?g ?gi (?t)) (imagingRequested ?physician ?patient) ) )
# (:- (s ?g G5 (?t)) (and (goal ?g ?gi ?a) (var ?g ?gi (?t)) (pathologyRequested ?physician ?pathologist ?patient) ) )

def s(g, gn, t)
  @state['goal'].any? {|terms|
    if terms.size == 3 and terms[0] == g and state('var', g, terms[1], t)
      case gn
      when G1 then @state['diagnosisRequested'].any? {|terms| terms.size == 2}
      when G2 then @state['diagnosisProvided'].any? {|terms| terms.size == 2}
      when G3 then @state['biopsyRequested'].any? {|terms| terms.size == 2}
      when G4 then @state['imagingRequested'].any? {|terms| terms.size == 2}
      when G5 then @state['pathologyRequested'].any? {|terms| terms.size == 3}
      end
    end
  }
end

# (:- (f ?g G1 (?t)) (and (goal ?g ?gi ?a) (var ?g ?gi (?t)) (dontknow ?patient) ))
# (:- (f ?g G2 (?t)) (and (goal ?g ?gi ?a) (var ?g ?gi (?t)) (dontknow ?patient) ))
# (:- (f ?g G3 (?t)) (and (goal ?g ?gi ?a) (var ?g ?gi (?t)) (dontknow ?patient) ))
# (:- (f ?g G4 (?t)) (and (goal ?g ?gi ?a) (var ?g ?gi (?t)) (dontknow ?patient) ))
# (:- (f ?g G5 (?t)) (and (goal ?g ?gi ?a) (var ?g ?gi (?t)) (dontknow ?patient) ))

def f(g, gn, t)
  if gn == G1 or gn == G2 or gn == G3 or gn == G4 or gn == G5
    @state['goal'].any? {|terms| terms.size == 3 and terms[0] == g and state('var', g, terms[1], t)} and @state['dontknow'].any? {|terms| terms.size == 1}
  end
end