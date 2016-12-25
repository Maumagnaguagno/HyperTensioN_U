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

def p(c, parameter1, cv)
  @state['commitment'].any? {|cterms|
    if cterms.size == 4 and cterm[0] == c and state('var', c, cterms[1], cv)
      d = cterms[2]
      a = cterms[3]
      case parameter1
      when 'C1' # (:- (p ?c C1 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (diagnosisRequested ?a ?d) (not (violated ?c C2 ?cv)) (not (violated ?c C3 ?cv)))))
        state('diagnosisRequested', a, d) and not violated(c, 'C2', cv) and not violated(c, 'C3', cv)
      when 'C2' # (:- (p ?c C2 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (iAppointmentRequested ?d ?radiologist))))
        @state['iAppointmentRequested'].any? {|terms| terms.size == 2 and terms[0] == d}
      when 'C3' # (:- (p ?c C3 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (bAppointmentRequested ?d ?pathologist))))
        @state['bAppointmentRequested'].any? {|terms| terms.size == 2 and terms[0] == d}
      when 'C4' # (:- (p ?c C4 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (biopsyRequested ?a ?patient) (bAppointmentKept ?patient ?a))))
        @state['biopsyRequested'].any? {|terms| terms.size == 2 and terms[0] == a and state('bAppointmentKept', terms[1], a)}
      when 'C5' # (:- (p ?c C5 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (imagingRequested ?a ?patient) (iAppointmentKept ?patient ?a))))
        @state['imagingRequested'].any? {|terms| terms.size == 2 and terms[0] == a and state('iAppointmentKept', terms[1], a)}
      when 'C6' # (:- (p ?c C6 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (pathologyRequested ?physician ?d ?patient) (tissueProvided ?patient))))
        @state['pathologyRequested'].any? {|terms| terms.size == 3 and terms[1] == d and state('tissueProvided', terms[2])}
      when 'C7' # (:- (p ?c C7 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (patientHasCancer ?patient))))
        @state['patientHasCancer'].any? {|terms| terms.size == 1}
      when 'C8' # (:- (p ?c C8 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (patientReportedToRegistrar ?patient ?d))))
        @state['patientReportedToRegistrar'].any? {|terms| terms[1] == d}
      when 'C9' # (:- (p ?c C9 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (violated ?c C5 ?cv) (escalate))))
        violated(c, 'C5', cv) and state('escalate')
      when 'C10' # (:- (p ?c C10 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (radRequestsAssessment))))
        state('radRequestsAssessment')
      when 'C11' # (:- (p ?c C11 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (phyRequestsAssessment))))
        state('phyRequestsAssessment')
      when 'C12' # (:- (p ?c C12 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (patRequestsAssessment))))
        state('patRequestsAssessment')
      end
    end
  }
end

def q(c, parameter1, cv)
  @state['commitment'].any? {|cterms|
    if cterms.size == 4 and cterms[0] == c and state('var', c, cterms[1], cv)
      d = cterms[2]
      a = cterms[3]
      case parameter1
      when 'C1' # (:- (q ?c C1 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (diagnosisProvided ?d ?a))))
        @state['diagnosisProvided'].any? {|terms| terms.size == 2 and terms[0] == d and terms[1] == a}
      when 'C2' # (:- (q ?c C2 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (iAppointmentKept ?d ?radiologist))))
        @state['iAppointmentKept'].any? {|terms| terms.size == 2 and terms[0] == d}
      when 'C3' # (:- (q ?c C3 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (bAppointmentKept ?d ?pathologist))))
        @state['bAppointmentKept'].any? {|terms| terms.size == 2 and terms[0] == d}
      when 'C4' # (:- (q ?c C4 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (radPathResultsReported ?d ?a ?patient))))
        @state['radPathResultsReported'].any? {|terms| terms.size == 3 and terms[0] == d and terms[1] == a}
      when 'C5' # (:- (q ?c C5 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (imagingResultsReported ?d ?a ?patient))))
        @state['imagingResultsReported'].any? {|terms| terms.size == 3 and terms[0] == d and terms[1] == a}
      when 'C6' # (:- (q ?c C6 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (pathResultsReported ?a ?physician ?patient))))
        @state['pathResultsReported'].any? {|terms| terms.size == 3 and terms[0] == a}
      when 'C7' # (:- (q ?c C7 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (patientReportedToRegistrar ?patient ?registrar))))
        @state['patientReportedToRegistrar'].any? {|terms| terms.size == 2}
      when 'C8' # (:- (q ?c C8 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (inRegistry ?patient))))
        @state['inRegistry'].any? {|terms| terms.size == 1}
      when 'C9' # (:- (q ?c C9 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (and (not (null ?c C5 ?ci)) (not (null ?c D5 ?ci)))))
        not null(c, 'C5', ci) and not null(c, 'D5', ci)
      when 'C10' # (:- (q ?c C10 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (or (TBAgreesPath) (TBDisagreesPath))))
        state('TBAgreesPath') or state('TBDisagreesPath')
      when 'C11' # (:- (q ?c C11 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (or (TBAgreesRad) (TBDisagreesRad))))
        state('TBAgreesRad') or state('TBDisagreesRad')
      when 'C12' # (:- (q ?c C12 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ?cv) (or (TBAgreesPCP) (TBDisagreesPCP))))
        state('TBAgreesPCP') or state('TBDisagreesPCP')
      end
    end
  }
end