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

def p(c, parameter1)
  # TODO complete this axiom
  case parameter1
  when 'C1' # (:- (p ?c C1 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (diagnosisRequested ?a ?d) (not (violated ?c C2 ?cv)) (not (violated ?c C3 ?cv))) ) )
    # TODO ci d a cv are free variables
    state('commitment', c, ci, d, a) and state('var', c, ci) and state('diagnosisRequested', a, d) and not violated(c, 'C2', cv) and not violated(c, 'C3', cv)
  when 'C2' # (:- (p ?c C2 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (iAppointmentRequested ?d ?radiologist))))
    # TODO ci d a radiologist are free variables
    state('commitment', c, ci, d, a) and state('var', c, ci) and state('iAppointmentRequested', d, radiologist)
  when 'C3' # (:- (p ?c C3 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (bAppointmentRequested ?d ?pathologist)) ) )
  when 'C4' # (:- (p ?c C4 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (biopsyRequested ?a ?patient) (bAppointmentKept ?patient ?a)) ) )
  when 'C5' # (:- (p ?c C5 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (imagingRequested ?a ?patient) (iAppointmentKept ?patient ?a)) ) )
  when 'C6' # (:- (p ?c C6 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (pathologyRequested ?physician ?d ?patient) (tissueProvided ?patient)) ))
  when 'C7' # (:- (p ?c C7 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (patientHasCancer ?patient)) ))
  when 'C8' # (:- (p ?c C8 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (patientReportedToRegistrar ?patient ?d)) ) )
  when 'C9' # (:- (p ?c C9 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (violated ?c C5 ?cv) (escalate)) ) )
  when 'C10' # (:- (p ?c C10 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (radRequestsAssessment)) ) )
  when 'C11' # (:- (p ?c C11 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (phyRequestsAssessment)) ) )
  when 'C12' # (:- (p ?c C12 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (patRequestsAssessment) ) ) )
  end
end

def q(c, parameter1)
  @state['commitment'].any? {|c, ci, d, a|
    case parameter1
    when 'C1' # (:- (q ?c C1 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (diagnosisProvided ?d ?a))))
      state('var', c, ci) and @state['diagnosisProvided'].any? {|term0, term1| term0 == d and term1 == a}
    when 'C2' # (:- (q ?c C2 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (iAppointmentKept ?d ?radiologist))))
      state('var', c, ci) and @state['iAppointmentKept'].any? {|term0, term1| term0 == d}
    when 'C3' # (:- (q ?c C3 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (bAppointmentKept ?d ?pathologist))))
      state('var', c, ci) and @state['bAppointmentKept'].any? {|term0, term1| term0 == d}
    when 'C4' # (:- (q ?c C4 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (radPathResultsReported ?d ?a ?patient))))
      state('var', c, ci) and @state['radPathResultsReported'].any? {|term0, term1, term2| term0 == d and term1 == a}
    when 'C5' # (:- (q ?c C5 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (imagingResultsReported ?d ?a ?patient))))
      state('var', c, ci) and @state['imagingResultsReported'].any? {|term0, term1, term2| term0 == d and term1 == a}
    when 'C6' # (:- (q ?c C6 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (pathResultsReported ?a ?physician ?patient))))
      state('var', c, ci) and @state['pathResultsReported'].any? {|term0, term1, term2| term0 == a}
    when 'C7' # (:- (q ?c C7 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (patientReportedToRegistrar ?patient ?registrar))))
      state('var', c, ci) and @state['patientReportedToRegistrar'].any? {|terms| terms.size == 2}
    when 'C8' # (:- (q ?c C8 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (inRegistry ?patient))))
      state('var', c, ci) and @state['inRegistry'].any? {|terms| terms.size == 1}
    when 'C9' # (:- (q ?c C9 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (not (null ?c C5 ?ci)) (not (null ?c D5 ?ci)))))
      state('var', c, ci) and not null(c, 'C5', ci) and not null(c, 'D5', ci)
    when 'C10' # (:- (q ?c C10 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (or (TBAgreesPath) (TBDisagreesPath))))
      state('var', c, ci) and (state('TBAgreesPath') or state('TBDisagreesPath'))
    when 'C11' # (:- (q ?c C11 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (or (TBAgreesRad) (TBDisagreesRad))))
      state('var', c, ci) and (state('TBAgreesRad') or state('TBDisagreesRad'))
    when 'C12' # (:- (q ?c C12 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (or (TBAgreesPCP) (TBDisagreesPCP))))
      state('var', c, ci) and (state('TBAgreesPCP') or state('TBDisagreesPCP'))
    end
  }
end
