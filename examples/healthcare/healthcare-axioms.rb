# Domain specific axioms
# C1(PHYSICIAN, PATIENT, diagnosisRequested ^ -vio(C2) ^ -vio(C3), diagnosisProvided)
# (:- (p ?c C1 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (diagnosisRequested ?a ?d) (not (violated ?c C2 ?cv)) (not (violated ?c C3 ?cv))) ) )
# (:- (q ?c C1 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (diagnosisProvided ?d ?a)) ) )

# C2(PATIENT, PHYSICIAN, iAppointmentRequested, iAppointmentKept)
# (:- (p ?c C2 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (iAppointmentRequested ?d ?radiologist))))
# (:- (q ?c C2 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (iAppointmentKept ?d ?radiologist))))

# C3(PATIENT, PHYSICIAN, bAppointmentRequested, bAppointmentKept)
# (:- (p ?c C3 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (bAppointmentRequested ?d ?pathologist)) ) )
# (:- (q ?c C3 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (bAppointmentKept ?d ?pathologist)) ) )

# C4(RADIOLOGIST, PHYSICIAN, biopsyRequested ^ bAppointmentKept, radPathResultsReported)
# (:- (p ?c C4 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (biopsyRequested ?a ?patient) (bAppointmentKept ?patient ?a)) ) )
# (:- (q ?c C4 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (radPathResultsReported ?d ?a ?patient)) ) )

# C5(RADIOLOGIST, PHYSICIAN, imagingRequested ^ iAppointmentKept, imagingResultsReported)
# (:- (p ?c C5 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (imagingRequested ?a ?patient) (iAppointmentKept ?patient ?a)) ) )
# (:- (q ?c C5 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (imagingResultsReported ?d ?a ?patient)) ) )

# C6(PATHOLOGIST, RADIOLOGIST, pathologyRequested ^ tissueProvided, pathResultsReported)
# (:- (p ?c C6 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (pathologyRequested ?physician ?d ?patient) (tissueProvided ?patient)) ))
# (:- (q ?c C6 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (pathResultsReported ?a ?physician ?patient)) ))

# C7(PATHOLOGIST, HOSPITAL, patientHasCancer, patientReportedToRegistrar)
# (:- (p ?c C7 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (patientHasCancer ?patient)) ))
# (:- (q ?c C7 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (patientReportedToRegistrar ?patient ?registrar)) ))

# C8(REGISTRAR, HOSPITAL, patientReportedToRegistrar, addPatientToCancerRegistry)
# (:- (p ?c C8 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (patientReportedToRegistrar ?patient ?d)) ) )
# (:- (q ?c C8 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (inRegistry ?patient)) ) )

# C9(HOSPITAL, PHYSICIAN, vio(C5) ^ escalate, create(C5') ^ create(D2')) - Does not work because it depends D5
# (:- (p ?c C9 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (violated ?c C5 ?cv) (escalate)) ) )
#; (:- (q ?c C9 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (create ?C5) (create ?D2)) ) )
# (:- (q ?c C9 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (not (null ?c C5 ?ci)) (not (null ?c D5 ?ci))) ) )

# C10(TUMORBOARD, RADIOLOGIST, radRequestsAssessment, TBAgreesPath _ TBDisagreesPath)
# (:- (p ?c C10 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (radRequestsAssessment)) ) )
# (:- (q ?c C10 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (or (TBAgreesPath) (TBDisagreesPath)) ))

# C11(TUMORBOARD, PHYSICIAN, phyRequestsAssessment, TBAgreesRad _ TBDisagreesRad)
# (:- (p ?c C11 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (phyRequestsAssessment)) ) )
# (:- (q ?c C11 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (or (TBAgreesRad) (TBDisagreesRad)) ) )

# C12(TUMORBOARD, PATIENT, patRequestsAssessment, TBAgreesPCP _ TBDisagreesPCP)
# (:- (p ?c C12 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (and (patRequestsAssessment) ) ) )
# (:- (q ?c C12 ) (and (commitment ?c ?ci ?d ?a) (var ?c ?ci ) (or (TBAgreesPCP) (TBDisagreesPCP) ) ) )

def p(c, parameter1)
  case parameter1
  when 'C1'
  when 'C2'
  when 'C3'
  when 'C4'
  when 'C5'
  when 'C6'
  when 'C7'
  when 'C8'
  when 'C9'
  when 'C10'
  when 'C11'
  when 'C12'
  end
end

def q(c, parameter1)
  case parameter1
  when 'C1'
  when 'C2'
  when 'C3'
  when 'C4'
  when 'C5'
  when 'C6'
  when 'C7'
  when 'C8'
  when 'C9'
  when 'C10'
  when 'C11'
  when 'C12'
  end
end
