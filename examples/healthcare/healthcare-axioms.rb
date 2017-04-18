# Domain specific axioms

# C1(PHYSICIAN, PATIENT, diagnosisRequested ^ -vio(C2) ^ -vio(C3), diagnosisProvided)
# C2(PATIENT, PHYSICIAN, iAppointmentRequested, iAppointmentKept)
# C3(PATIENT, PHYSICIAN, bAppointmentRequested, bAppointmentKept)
# C4(RADIOLOGIST, PHYSICIAN, imagingRequested ^ iAppointmentKept, imagingResultsReported)
# C5(RADIOLOGIST, PHYSICIAN, biopsyRequested ^ bAppointmentKept, radPathResultsReported)
# C6(PATHOLOGIST, RADIOLOGIST, pathologyRequested ^ tissueProvided, pathResultsReported)
# C7(REGISTRAR, PATHOLOGIST, reportPatientWithCancer, addPatientToRegistry)

# (:- (p C1 ?ci (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (diagnosisRequested ?a ?d) (not (violated ?c C2 (?t))) (not (violated ?c C3 (?t)))) ) )
# (:- (p C2 ?ci (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (iAppointmentRequested ?d ?radiologist))))
# (:- (p C3 ?ci (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (bAppointmentRequested ?d ?pathologist)) ) )
# (:- (p C4 ?ci (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (imagingRequested ?a ?t) (iAppointmentKept ?t ?d) ) ) )
# (:- (p C5 ?ci (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (biopsyRequested ?a ?patient) (bAppointmentKept ?patient ?d)) ) )
# (:- (p C6 ?ci (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (pathologyRequested ?physician ?d ?patient) (tissueProvided ?patient)) ))
# (:- (p C7 ?ci (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (patientReportedToRegistrar ?t ?d)) ) )

def p(cn, ci, t)
  @state['commitment'].any? {|cterms|
    c = cterms[0]
    if cterms.size == 4 and cterms[1] == ci and state('var', c, ci, t)
      d = cterms[2]
      a = cterms[3]
      case cn
      when C1 then state('diagnosisRequested', a, d) and not violated(c, C2, t) and not violated(c, C3, t)
      when C2 then @state['iAppointmentRequested'].any? {|terms| terms.size == 2 and terms[0] == d}
      when C3 then @state['bAppointmentRequested'].any? {|terms| terms.size == 2 and terms[0] == d}
      when C4 then @state['imagingRequested'].any? {|terms| terms.size == 2 and terms[0] == a and list(terms[1]) == t and state('iAppointmentKept', terms[1], d)}
      when C5 then @state['biopsyRequested'].any? {|terms| terms.size == 2 and terms[0] == a and state('bAppointmentKept', terms[1], d)}
      when C6 then @state['pathologyRequested'].any? {|terms| terms.size == 3 and terms[1] == d and state('tissueProvided', terms[2])}
      when C7 then @state['patientReportedToRegistrar'].any? {|terms| terms.size == 2 and list(terms[0]) == t and terms[1] == d}
      end
    end
  }
end

# (:- (q C1 ?ci (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (diagnosisProvided ?d ?a)) ) )
# (:- (q C2 ?ci (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (iAppointmentKept ?d ?radiologist))))
# (:- (q C3 ?ci (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (bAppointmentKept ?d ?pathologist)) ) )
# (:- (q C4 ?ci (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (imagingResultsReported ?d ?a ?t)) ) )
# (:- (q C5 ?ci (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (radPathResultsReported ?d ?a ?patient)) ) )
# (:- (q C6 ?ci (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (pathResultsReported ?a ?physician ?patient)) ))
# (:- (q C7 ?ci (?t)) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci (?t)) (and (inRegistry ?t)) ) )

def q(cn, ci, t)
  @state['commitment'].any? {|cterms|
    c = cterms[0]
    if cterms.size == 4 and cterms[1] == ci and state('var', c, ci, t)
      d = cterms[2]
      a = cterms[3]
      case cn
      when C1 then @state['diagnosisProvided'].any? {|terms| terms.size == 2 and terms[0] == d and terms[1] == a}
      when C2 then @state['iAppointmentKept'].any? {|terms| terms.size == 2 and terms[0] == d}
      when C3 then @state['bAppointmentKept'].any? {|terms| terms.size == 2 and terms[0] == d}
      when C4 then @state['imagingResultsReported'].any? {|terms| terms.size == 3 and terms[0] == d and terms[1] == a and list(terms[2]) == t}
      when C5 then @state['radPathResultsReported'].any? {|terms| terms.size == 3 and terms[0] == d and terms[1] == a}
      when C6 then @state['pathResultsReported'].any? {|terms| terms.size == 3 and terms[0] == a}
      when C7 then @state['inRegistry'].any? {|terms| terms.size == 1 and list(terms[0]) == t}
      end
    end
  }
end

# G1 = G(PHYSICIAN, diagnosisRequested, - diagnosisRequested)
# G2 = G(PATIENT, diagnosisRequested, - diagnosisRequested)
# G3 = G(RADIOLOGIST, imagingRequested ^ iAppointmentRequested, - imagingRequested v - iAppointmentRequested)
# G4 = G(PHYSICIAN, imgagingRequested ^ iAppointmentRequested, - imagingRequested v - iAppointmentRequested)
# G6 = G(PATIENT, iAppointmentKept, - iAppointmentKept)
# G7 = G(RADIOLOGIST, imagingResultsReported, - imagingResultsReported)
# G8 = G(RADIOLOGIST, biopsyRequested ^ bAppointmentRequested, - biopsyRequested V - bAppointmentRequested)
# G9 = G(PHYSICIAN, biopsyRequested ^ bAppointmentRequested, - biopsyRequested v - bAppointmentRequested)
# G11 = G(PATIENT, bAppointmentKept, - bAppointmentKept)
# G12 = G(PATHOLOGIST, pathologyRequested ^ tissueProvided, - pathologyRequested V - tissueProvided)
# G13 = G(RADIOLOGIST, pathologyRequested ^ tissueProvided, - pathologyRequested v -tissueProvided)
# G15 = G(PATHOLOGIST, pathResultsReported, - pathResultsReported)
# G16 = G(RADIOLOGIST, radPathResultsReported, - radPathResultsReported)
# G17 = G(REGISTRAR, reportPatientWithCancer, - reportPatientWithCancer)
# G18 = G(PATHOLOGIST, reportPatientWithCancer, - reportPatientWithCancer)
# G19 = G(REGISTRAR, addPatientToRegistry, - addPatientToRegistry)

# (:- (pg G1 ?gi (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg G2 ?gi (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg G3 ?gi (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg G4 ?gi (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg G6 ?gi (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg G7 ?gi (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg G8 ?gi (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg G9 ?gi (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg G11 ?gi (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg G12 ?gi (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg G13 ?gi (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg G15 ?gi (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg G16 ?gi (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg G17 ?gi (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg G18 ?gi (?t)) (and (goal ?g ?gi ?a) ) )
# (:- (pg G19 ?gi (?t)) (and (goal ?g ?gi ?a) ) )

def pg(gn, gi, t)
  if gn == G1 or gn == G2 or gn == G3 or gn == G4 or
     gn == G6 or gn == G7 or gn == G8 or gn == G9 or
     gn == G11 or gn == G12 or gn == G13 or gn == G15 or
     gn == G16 or gn == G17 or gn == G18 or gn == G19
    @state['goal'].any? {|terms| terms.size == 3 and terms[1] == gi}
  end
end

# (:- (s  G1 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (diagnosisRequested ?t ?a) ) )
# (:- (s  G2 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (diagnosisRequested ?a ?physician) ) )
# (:- (s  G3 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (imagingRequested ?physician ?t) (iAppointmentRequested ?t ?a) ) )
# (:- (s  G4 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (imagingRequested ?a ?t) ) )
# (:- (s  G6 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (iAppointmentKept ?a ?radiologist) ) )
# (:- (s  G7 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (imagingResultsReported ?a ?physician ?t) ) )
# (:- (s  G8 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) ((biopsyRequested ?physician ?t) (bAppointmentRequested ?t ?pathologist)) ) )
# (:- (s  G9 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (biopsyRequested ?a ?t) (bAppointmentRequested ?t ?pathologist) ) )
# (:- (s  G11 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (bAppointmentKept ?a ?pathologist) ) )
# (:- (s  G12 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (pathologyRequested ?physician ?a ?t) (tissueProvided ?t)) )
# (:- (s  G13 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (pathologyRequested ?physician ?d ?t) (tissueProvided ?t)) )
# (:- (s  G15 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (pathResultsReported ?radiologist ?physician ?t)) )
# (:- (s  G16 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (integratedReport ?t ?physician) ) )
# (:- (s  G17 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (patientReportedToRegistrar ?t ?a)) )
# (:- (s  G18 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (patientReportedToRegistrar ?t ?registrar)) )
# (:- (s  G19 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (inRegistry ?t)) )

def s(gn, gi, t)
  @state['goal'].any? {|terms|
    g = terms[0]
    if terms.size == 3 and terms[1] == gi and state('varG', g, gi, t)
      a = terms[2]
      case gn
      when G1 then @state['diagnosisRequested'].any? {|terms2| terms2.size == 2 and list(terms2[0]) == t and terms2[1] == a}
      when G2 then @state['diagnosisRequested'].any? {|terms2| terms2.size == 2 and terms2[0] == a}
      when G3 then @state['imagingRequested'].any? {|terms2| terms2.size == 2 and terms2[1] == t and @state['iAppointmentRequested'].any? {|terms3| terms3.size == 2 and terms3[0] == t and terms3[1] == a}}
      when G4 then @state['imagingRequested'].any? {|terms2| terms2.size == 2 and terms2[0] == a and list(terms2[1]) == t}
      when G6 then @state['iAppointmentKept'].any? {|terms2| terms2.size == 2 and terms2[0] == a}
      when G7 then @state['imagingResultsReported'].any? {|terms2| terms2.size == 3 and terms2[0] == a and list(terms2[2]) == t}
      when G8 then @state['biopsyRequested'].any? {|terms2| terms2.size == 2 and terms2[1] == t and @state['bAppointmentRequested'].any? {|terms3| terms3.size == 2 and terms3[0] == t}}
      when G9 then @state['biopsyRequested'].any? {|terms2| terms2.size == 2 and terms2[0] == a and list(terms2[1]) == t and @state['bAppointmentRequested'].any? {|terms3| terms3.size == 2 and list(terms3[0]) == t}}
      when G11 then @state['bAppointmentKept'].any? {|terms2| terms2.size == 2 and terms2[0] == a}
      when G12 then @state['pathologyRequested'].any? {|terms2| terms2.size == 3 and terms2[1] == a and terms2[2] == t and state('tissueProvided', t)}
      when G13 then @state['pathologyRequested'].any? {|terms2| terms2.size == 3 and list(terms2[2]) == t and state('tissueProvided', terms2[2])}
      when G15 then @state['pathResultsReported'].any? {|terms2| terms2.size == 3 and list(terms2[2]) == t}
      when G16 then @state['integratedReport'].any? {|terms2| terms2.size == 2 and list(terms2[0]) == t}
      when G17 then @state['patientReportedToRegistrar'].any? {|terms2| terms2.size == 2 and list(terms2[0]) == t and terms2[1] == a}
      when G18 then @state['patientReportedToRegistrar'].any? {|terms2| terms2.size == 2 and terms2[0] == t}
      when G19 then @state['inRegistry'].any? {|terms2| terms2.size == 1 and list(terms2[0]) == t}
      end
    end
  }
end

# (:- (f  G1 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?a) ))
# (:- (f  G2 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?a) ))
# (:- (f  G3 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?patient) ))
# (:- (f  G4 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?patient) ))
# (:- (f  G6 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?a) ))
# (:- (f  G7 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?patient) ))
# (:- (f  G8 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?patient) ))
# (:- (f  G9 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?a) ))
# (:- (f  G11 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?a) ))
# (:- (f  G12 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?t) ))
# (:- (f  G13 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?patient) ))
# (:- (f  G15 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?patient) ))
# (:- (f  G16 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?patient) ))
# (:- (f  G17 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?patient) ))
# (:- (f  G18 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?patient) ))
# (:- (f  G19 ?gi (?t)) (and (goal ?g ?gi ?a) (varG ?g ?gi (?t)) (dontknow ?patient) ))

def f(gn, gi, t)
  @state['goal'].any? {|terms|
    if terms.size == 3 and terms[1] == gi and state('varG', terms[0], gi, t)
      a = terms[2]
      case gn
      when G1, G2, G6, G9, G11 then @state['dontknow'].any? {|terms2| terms2.size == 1 and terms2[0] == a}
      when G3, G4, G7, G8, G13, G15, G16, G17, G18, G19 then @state['dontknow'].any? {|terms2| terms2.size == 1}
      when G12 then @state['dontknow'].any? {|terms2| terms2.size == 1 and terms2[0] == t}
      end
    end
  }
end