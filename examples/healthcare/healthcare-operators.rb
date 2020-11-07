# Domain dependent operators

# (:operator (!requestAssessment ?patient ?physician)
#   () ; Pre
#   () ; Del
#   ((diagnosisRequested ?patient ?physician)) ; Add
#   1 ; Cost
# )

def requestAssessment(patient, physician)
  apply([[DIAGNOSISREQUESTED, patient, physician]], [])
end

# (:operator (!requestImaging ?physician ?patient ?radiologist)
#   (and (physician ?physician) (patient ?patient) (radiologist ?radiologist)) ;Pre
#   () ;Del
#   ((iAppointmentRequested ?patient ?radiologist) (imagingRequested ?physician ?patient)) ;Add
#   1 ; Cost
# )

def requestImaging(physician, patient, radiologist)
  if state(PHYSICIAN, physician) and state(PATIENT, patient) and state(RADIOLOGIST, radiologist)
    apply([[IAPPOINTMENTREQUESTED, patient, radiologist], [IMAGINGREQUESTED, physician, patient]], [])
  end
end

# (:operator (!requestBiopsy ?physician ?patient ?radiologist)
#   (and (physician ?physician) (patient ?patient) (radiologist ?radiologist)) ;Pre
#   () ;Del
#   ((bAppointmentRequested ?patient ?radiologist) (biopsyRequested ?physician ?patient)) ;Add
#   1 ; Cost
# )

def requestBiopsy(physician, patient, radiologist)
  if state(PHYSICIAN, physician) and state(PATIENT, patient) and state(RADIOLOGIST, radiologist)
    apply([[BAPPOINTMENTREQUESTED, patient, radiologist], [BIOPSYREQUESTED, physician, patient]], [])
  end
end

# ;; PT: performImaging and sendImagingResults can be combined.

# (:operator (!performImaging ?radiologist ?patient ?physician)
#   (and (patient ?patient) (radiologist ?radiologist) (physician ?physician) (iAppointmentRequested ?patient ?radiologist)) ; Pre
#   ( (iAppointmentRequested ?patient ?radiologist) ) ; Del
#   ((imagingScan ?patient ?physician) (iAppointmentKept ?patient ?radiologist)) ; Add
#   1 ; Cost
# )

def performImaging_success(radiologist, patient, physician)
  if state(PATIENT, patient) and state(RADIOLOGIST, radiologist) and state(PHYSICIAN, physician) and state(IAPPOINTMENTREQUESTED, patient, radiologist)
    apply(
      [
        [IMAGINGSCAN, patient, physician],
        [IAPPOINTMENTKEPT, patient, radiologist]
      ],
      [
        [IAPPOINTMENTREQUESTED, patient, radiologist]
      ]
    )
  end
end
alias :performImaging :performImaging_success

def performImaging_failure(radiologist, patient, physician)
  state(PATIENT, patient) and state(RADIOLOGIST, radiologist) and state(PHYSICIAN, physician) and state(IAPPOINTMENTREQUESTED, patient, radiologist)
end

# ;; Change this to have the radiologist doing the biopsy
# (:operator (!performBiopsy ?radiologist ?patient ?physician)
#   (and (patient ?patient) (radiologist ?radiologist) (physician ?physician)) ; Pre
#   ((bAppointmentRequested ?patient ?radiologist)) ; Del
#   ((biopsyReport ?patient ?physician) (bAppointmentKept ?patient ?radiologist) (tissueProvided ?patient) ) ; Add
#   1 ; Cost
# )

def performBiopsy_success(radiologist, patient, physician)
  if state(PATIENT, patient) and state(RADIOLOGIST, radiologist) and state(PHYSICIAN, physician)
    apply(
      [
        [BIOPSYREPORT, patient, physician],
        [BAPPOINTMENTKEPT, patient, radiologist],
        [TISSUEPROVIDED, patient]
      ],
      [
        [BAPPOINTMENTREQUESTED, patient, radiologist]
      ]
    )
  end
end
alias :performBiopsy :performBiopsy_success

def performBiopsy_failure(radiologist, patient, physician)
  state(PATIENT, patient) and state(RADIOLOGIST, radiologist) and state(PHYSICIAN, physician)
end

# ;; Instead of performDiagnosis, we need:
# ;; (A) requestPathologyReport operator; radiologist requests a pathologist for pathology report
# ;; (B) requestRadiologyReport operator; pathologist requests a radiologist for radiology report
# (:operator (!requestPathologyReport ?physician ?radiologist ?patient)
#   (and (physician ?physician) (pathologist ?pathologist) (radiologist ?radiologist) (patient ?patient) (biopsyReport ?patient ?physician) ) ; Pre
#   () ; Del
#   ((pathologyRequested ?physician ?pathologist ?patient)) ; Add
#   1 ; Cost
# )

def requestPathologyReport(physician, radiologist, pathologist, patient)
  if state(PHYSICIAN, physician) and state(PATHOLOGIST, pathologist) and state(RADIOLOGIST, radiologist) and state(PATIENT, patient) and state(BIOPSYREPORT, patient, physician)
    apply([[PATHOLOGYREQUESTED, physician, pathologist, patient]], [])
  end
end

# (:operator (!requestRadiologyReport ?physician ?radiologist ?patient)
#   (and (physician ?physician) (radiologist ?radiologist) (patient ?patient) (imagingScan ?patient ?physician)) ; Pre
#   () ; Del
#   ((radiologyRequested ?physician ?radiologist ?patient)) ; Add
#   1 ; Cost
# )

def requestRadiologyReport(physician, radiologist, patient)
  if state(PHYSICIAN, physician) and state(RADIOLOGIST, radiologist) and state(PATIENT, patient) and state(IMAGINGSCAN, patient, physician)
    apply([[RADIOLOGYREQUESTED, physician, radiologist, patient]], [])
  end
end

# (:operator (!sendPathologyReport ?radiologist ?physician ?patient)
#   (and (physician ?physician) (radiologist ?radiologist) (patient ?patient) (biopsyReport ?patient ?physician) (pathologyRequested ?physician ?pathologist ?patient))
#   () ;Del
#   ( (radPathResultsReported ?radiologist ?physician ?patient) (pathResultsReported ?radiologist ?physician ?patient) ) ;Add
# )

def sendPathologyReport(radiologist, physician, pathologist, patient)
  if state(PHYSICIAN, physician) and state(RADIOLOGIST, radiologist) and state(PATIENT, patient) and state(BIOPSYREPORT, patient, physician) and state(PATHOLOGYREQUESTED, physician, pathologist, patient)
    apply(
      [
        [RADPATHRESULTSREPORTED, radiologist, physician, patient],
        [PATHRESULTSREPORTED, radiologist, physician, patient]
      ],
      []
    )
  end
end

# (:operator (!sendRadiologyReport ?radiologist ?physician ?patient)
#   (and (physician ?physician) (radiologist ?radiologist) (patient ?patient) (imagingScan ?patient ?physician)
#        ;(biopsyReport ?patient ?physician)
#        (radiologyRequested ?physician ?radiologist ?patient))
#   () ;Del
#   ( (imagingResultsReported ?radiologist ?physician ?patient) ) ;Add
# )

def sendRadiologyReport(radiologist, physician, patient)
  if state(PHYSICIAN, physician) and state(RADIOLOGIST, radiologist) and state(PATIENT, patient) and state(IMAGINGSCAN, patient, physician) and state(RADIOLOGYREQUESTED, physician, radiologist, patient)
    apply([[IMAGINGRESULTSREPORTED, radiologist, physician, patient]], [])
  end
end

# (:operator (!sendIntegratedReport ?radiologist ?pathologist ?patient ?physician)
#   (and (radPathResultsReported ?radiologist ?physician ?patient)
#     (imagingResultsReported ?radiologist ?physician ?patient)
#     (radiologist ?radiologist) (physician ?physician)
#     (patient ?patient) (pathologist ?pathologist)) ; Pre
#   ;((radPathResultsReported ?radiologist ?physician ?patient) (imagingResultsReported ?radiologist ?physician ?patient)) ; Del
#   nil
#   ((integratedReport ?patient ?physician) (diagnosisProvided ?physician ?patient)) ; Add
#   1 ; Cost
# )

def sendIntegratedReport(radiologist, pathologist, patient, physician)
  if state(RADPATHRESULTSREPORTED, radiologist, physician, patient) and state(IMAGINGRESULTSREPORTED, radiologist, physician, patient) and state(RADIOLOGIST, radiologist) and state(PHYSICIAN, physician) and state(PATIENT, patient) and state(PATHOLOGIST, pathologist)
    apply(
      [
        [INTEGRATEDREPORT, patient, physician],
        [DIAGNOSISPROVIDED, physician, patient]
      ],
      []
    )
  end
end

# (:operator (!generateTreatmentPlan ?physician ?patient)
#   (and (patient ?patient) (physician ?physician) (imagingScan ?patient ?physician) ;(integratedReport ?patient ?physician) ;<- This should not be a precondition (since only imaging may do)) ; Pre
#   () ; Del
#   ((treatmentPlan ?physician ?patient) (diagnosisProvided ?physician ?patient)) ; Add
#   1 ; Cost
# )

def generateTreatmentPlan(physician, patient)
  if state(PATIENT, patient) and state(PHYSICIAN, physician) and state(IMAGINGSCAN, patient, physician)
    apply(
      [
        [TREATMENTPLAN, physician, patient],
        [DIAGNOSISPROVIDED, physician, patient]
      ],
      []
    )
  end
end

# (:operator (!reportPatient ?patient ?pathologist ?registrar)
#   (and (patient ?patient) (pathologist ?pathologist) (registrar ?registrar) (patientHasCancer ?patient)) ; Pre
#   () ; Del
#   ( (patientReportedToRegistrar ?patient ?registrar) ) ; Add
#   1 ; Cost
# )

def reportPatient(patient, pathologist, registrar)
  if state(PATIENT, patient) and state(PATHOLOGIST, pathologist) and state(REGISTRAR, registrar) and state(PATIENTHASCANCER, patient)
    apply([[PATIENTREPORTEDTOREGISTRAR, patient, registrar]], [])
  end
end

# (:operator (!addPatientToRegistry ?patient ?registrar)
#   (and (patient ?patient) (registrar ?registrar) (patientReportedToRegistrar ?patient ?registrar)) ; Pre
#   () ; Del
#   ( (inRegistry ?patient) ) ; Add
#   1 ; Cost
# )

def addPatientToRegistry(patient, registrar)
  if state(PATIENT, patient) and state(REGISTRAR, registrar) and state(PATIENTREPORTEDTOREGISTRAR, patient, registrar)
    apply([[INREGISTRY, patient]], [])
  end
end


# ;; TODO Add operators to re-assign radiologist (perhaps through appointment)
# (:operator (!escalateFailure ?patient ?physician ?radiologist ?hospital)
#   (and (radiologist ?radiologist) (physician ?physician) (patient ?patient) (hospital ?hospital) (not (imagingScan ?patient ?radiologist)) ) ; Pre
#   () ; Del
#   ( (radiologistReported ?patient ?physician ?radiologist ?hospital)) ; Add
#   1 ; Cost
# )

def escalateFailure(patient, physician, radiologist, hospital)
  if state(RADIOLOGIST, radiologist) and state(PHYSICIAN, physician) and state(PATIENT, patient) and state(HOSPITAL, hospital) and not state(IMAGINGSCAN, patient, radiologist)
    apply([[RADIOLOGISTREPORTED, patient, physician, radiologist, hospital]], [])
  end
end

# ;; TODO Ask Pankaj about how this works

# ;; Patient, Physician, Radiologist, or Pathologist can request Tumor Board (TB) for assessment of a
# ;; report sent to them by a counter party.
# ;; (A) Patient can request TB to assess Physician's report; TB either agrees or disagrees
# ;; with Physician's report.
# ;; FIXME FRM - Pankaj, so far, I had not seen a "physician's" report, I'm assuming this is the treatment plan
# ;; (B) Physician can request TB to assess the "integratedReport" sent by Radiologist; TB either agrees
# ;; or disagrees with Radiologist's report.
# ;; FIXME FRM - Pankaj, I'm not sure I understand that the integrated report is created by the radiologist
# ;; (C) Pathologist can request TB to assess Radiologist's report; TB either agrees or disagress
# ;;  with Radiologist's report.
# ;; (D) Radiologist can request TB to assess Pathologist's report; TB either agrees or disagress
# ;; with Pathologist's report.

# ; (:operator (!requestTumorBoardInput ?person ?patient ?physician ?hospital)
# ;   (and (hospital ?hospital)
# ;     (patient ?patient) (physician ?physician)
# ;     (or (patient ?person) (radiologist ?person) (physician ?person) (pathologist ?person))
# ;     (integratedReport ?patient ?physician)
# ;   ) ; Pre
# ;   () ; Del
# ;   () ; Add
# ;   1 ; Cost
# ; )

# ; Patient requests assessment of physician report
# (:operator (!requestPhysicianReportAssessment ?patient ?physician ?hospital)
#   (and (hospital ?hospital)
#     (patient ?patient) (physician ?physician)
#     (integratedReport ?patient ?physician)
#     ) ; Pre
#   () ; Del
#   ((reportNeedsReview ?patient ?physician)) ; Add # Option 1, TB disagrees
#     ; () ; Add # Option 2, TB agrees with physician (nothing happens)
#   1 ; Cost
# )

def requestPhysicianReportAssessment(patient, physician, hospital)
  if state(HOSPITAL, hospital) and state(PATIENT, patient) and state(PHYSICIAN, physician) and state(INTEGRATEDREPORT, patient, physician)
    apply([[REPORTNEEDSREVIEW, patient, physician]], [])
  end
end

# (:operator (!requestRadiologyReportAssessment ?pathologist ?radiologist ?patient ?hospital)
#   (and (hospital ?hospital)
#     (patient ?patient) (pathologist ?pathologist) (radiologist ?radiologist)
#     (radiologyReport ?patient ?radiologist)
#   ) ; Pre
#   () ; Del
#   ((reportNeedsReview ?patient ?radiologist)) ; Add # Option 1, TB disagrees
#   ; () ; Add # Option 2, TB agrees with radiologist (nothing happens)
#   1 ; Cost
# )

def requestRadiologyReportAssessment(pathologist, radiologist, patient, hospital)
  if state(HOSPITAL, hospital) and state(PATIENT, patient) and state(PATHOLOGIST, pathologist) and state(RADIOLOGIST, radiologist) and state(RADIOLOGYREPORT, patient, radiologist)
    apply([[REPORTNEEDSREVIEW, patient, radiologist]], [])
  end
end

# (:operator (!requestPathologyReportAssessment ?radiologist ?pathologist ?patient ?hospital)
#   (and (hospital ?hospital)
#     (patient ?patient) (pathologist ?pathologist) (radiologist ?radiologist)
#     (pathologyReport ?patient ?pathologist)
#   ) ; Pre
#   () ; Del
#   ((reportNeedsReview ?patient ?pathologist)) ; Add # Option 1, TB disagrees
#   ; () ; Add # Option 2, TB agrees with pathologist (nothing happens)
#   1 ; Cost
# )

def requestPathologyReportAssessment(radiologist, pathologist, patient, hospital)
  if state(HOSPITAL, hospital) and state(PATIENT, patient) and state(PATHOLOGIST, pathologist) and state(RADIOLOGIST, radiologist) and state(PATHOLOGYREPORT, patient, pathologist)
    apply([[REPORTNEEDSREVIEW, patient, pathologist]], [])
  end
end