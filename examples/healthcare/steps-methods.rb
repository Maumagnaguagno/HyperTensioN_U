# Steps

# (:method (step1 ?patient)
#   (
#     (patient ?patient)
#     (physician ?physician)
#     (radiologist ?radiologist)
#     (commitment C1 ?c1_patient ?physician ?patient)
#     (commitment C2 ?c2_patient ?patient ?physician)
#     (commitment C3 ?c3_patient ?patient ?physician)
#   )
#   (
#     (!consider G1 G1 ?physician (?patient) )
#     (!activate G1 G1 ?physician (?patient) )

#     ; Physician employs ENTICE rule to create C1
#     (entice G1 G1 (?patient) C1 ?c1_patient (?patient) ?physician ?patient)

#     ; Patient employs DETACH for C1 which results in considering and activating of G2
#     (detach G2 G2 (?patient) C1 ?c1_patient (?patient) ?physician ?patient)

#     ; TODO: DETACH should also create C2 and C3. Since it does not, creating
#     ; C2 and C3 explicitly
#     (!create C2 ?c2_patient ?patient ?physician (?radiologist))
#     (!create C3 ?c3_patient ?patient ?physician (?radiologist))

#     ; Patient brings about requestAssessment
#     (!requestAssessment ?patient ?physician)

#     ; The above should satisfy G1 and G2 and detach C1
#     (testGoal G1 G1 (?patient) satisfied)
#     (testGoal G2 G2 (?patient) satisfied)
#     (testCommitment C1 ?c1_patient (?patient) detached)
#   )
# )

def step1(patient)
  physician = ''
  radiologist = ''
  c1_patient = ''
  c2_patient = ''
  c3_patient = ''
  generate(
    [
      ['patient', patient],
      ['physician', physician],
      ['radiologist', radiologist],
      ['commitment', C1, c1_patient, physician, patient],
      ['commitment', C2, c2_patient, patient, physician],
      ['commitment', C3, c3_patient, patient, physician]
    ],
    [], physician, radiologist, c1_patient, c2_patient, c3_patient
  ) {
    yield [
      ['consider', G1, G1, physician, list(patient)],
      ['activate', G1, G1, physician, list(patient)],
      ['entice', G1, G1, list(patient), C1, c1_patient, list(patient), physician, patient],

      ['detach', G2, G2, list(patient), C1, c1_patient, list(patient), physician, patient],

      ['create', C2, c2_patient, patient, physician, list(radiologist)],
      ['create', C3, c3_patient, patient, physician, list(radiologist)],
      ['requestAssessment', patient, physician],

      ['testGoal', G1, G1, list(patient), 'satisfied'],
      ['testGoal', G2, G2, list(patient), 'satisfied'],
      ['testCommitment', C1, c1_patient, list(patient), 'detached']
    ]
  }
end

# (:method (step2 ?patient)
#   (
#     (patient ?patient)
#     (physician ?physician)
#     (radiologist ?radiologist)
#     (commitment C2 ?c2_patient ?patient ?physician)
#     (commitment C4 ?c4_patient ?radiologist ?physician)
#   )
#   (
#     ; Radiologist considers and activates G3
#     (!consider G3 G3 ?radiologist (?patient) )
#     (!activate G3 G3 ?radiologist (?patient) )

#     ; Radiologist employs ENTICE for G3 to create C4
#     (entice G3 G3 (?patient) C4 ?c4_patient (?patient) ?radiologist ?physician)

#     ; Physician employs DETACH for C4 to create G4
#     (detach G4 G4 (?patient) C4 ?c4_patient (?patient) ?radiologist ?physician)

#     ; Physician brings about imagingRequested and iAppointmentRequested
#     (!requestImaging ?physician ?patient ?radiologist)

#     ; The above should satisfy G4 and detach C2
#     (testGoal G4 G4 (?patient) satisfied)
#     (testCommitment C2 ?c2_patient (?radiologist) detached)

#     ; Patient employs DELIVER for C2 to consider and activate goal G6
#     (deliver G6 G6 (?patient) C2 ?c2_patient (?radiologist) ?patient ?physician)

#     ; Patient brings about iAppointmentKept
#     (attendTest ?patient)
#     (testCommitment C4 ?c4_patient (?patient) detached) ; TODO This won't detach C4 because it also requires the imaging appotintment to have been kept (this only happens attendTest below)

#     ; The above should satisfy G6 and C2
#     (testGoal G6 G6 (?patient) satisfied)
#     (testCommitment C2 ?c2_patient (?radiologist) satisfied)

#     ; Radiologist employs DELIVER for C4 to consider and activate goal G7
#     (deliver G7 G7 (?radiologist) C4 ?c4_patient (?patient) ?radiologist ?physician)

#     ; Physician requests radiology report
#     (!requestRadiologyReport ?physician ?radiologist ?patient)
#     ; Radiologist brings about imagingResultsReported
#     (!sendRadiologyReport ?radiologist ?physician ?patient)

#     ; The above should satisfy G7 and C4
#     (testGoal G7 G7 (?radiologist) satisfied)
#     (testCommitment C4 ?c4_patient (?patient) satisfied)
#   )
# )

def step2(patient)
  physician = ''
  radiologist = ''
  c2_patient = ''
  c4_patient = ''
  generate(
    [
      ['patient', patient],
      ['physician', physician],
      ['radiologist', radiologist],
      ['commitment', C2, c2_patient, patient, physician],
      ['commitment', C4, c4_patient, radiologist, physician]
    ],
    [], physician, radiologist, c2_patient, c4_patient
  ) {
    yield [
      ['consider', G3, G3, radiologist, list(patient)],
      ['activate', G3, G3, radiologist, list(patient)],
      ['entice', G3, G3, list(patient), C4, c4_patient, list(patient), radiologist, physician],
      ['detach', G4, G4, list(patient), C4, c4_patient, list(patient), radiologist, physician],
      ['requestImaging', physician, patient, radiologist],
      ['testGoal', G4, G4, list(patient), 'satisfied'],
      ['testCommitment', C2, c2_patient, list(radiologist), 'detached'],
      ['deliver', G6, G6, list(patient), C2, c2_patient, list(radiologist), patient, physician],
      ['attendTest', patient],
      ['testCommitment', C4, c4_patient, list(patient), 'detached'],
      ['testGoal', G6, G6, list(patient), 'satisfied'],
      ['testCommitment', C2, c2_patient, list(radiologist), 'satisfied'],
      ['deliver', G7, G7, list(radiologist), C4, c4_patient, list(patient), radiologist, physician],
      ['requestRadiologyReport', physician, radiologist, patient],
      ['sendRadiologyReport', radiologist, physician, patient],
      ['testGoal', G7, G7, list(radiologist), 'satisfied'],
      ['testCommitment', C4, c4_patient, list(patient), 'satisfied']
    ]
  }
end

# (:method (step3 ?patient)
#   (
#     (patient ?patient)
#     (physician ?physician)
#     (radiologist ?radiologist)
#     (commitment C3 ?c3_patient ?patient ?physician)
#     (commitment C5 ?c5_patient ?radiologist ?physician)
#   )
#   (
#     ; Radiologist considers and activates goal G8
#     (!consider G8 G8 ?radiologist (?patient) )
#     (!activate G8 G8 ?radiologist (?patient) )

#     ; Radiologist employs ENTICE for G8 to create commitment C5
#     (entice G8 G8 (?patient) C5 ?c5_patient (?patient) ?radiologist ?physician)

#     ; Physician employs DETACH for C5 to consider and activate goal G9
#     (detach G9 G9 (?patient) C5 ?c5_patient (?patient) ?radiologist ?physician)

#     ; Physician brings about biopsyRequested and bAppointmentRequested.
#     (!requestBiopsy ?physician ?patient ?radiologist)

#     ; The above should satisfy G9 and detach C3
#     (testGoal G9 G9 (?patient) satisfied)
#     (testCommitment C3 ?c3_patient (?radiologist) detached)

#     ; Patient employs DELIVER for C3 to consider and activate goal G11
#     (deliver G11 G11 (?patient) C3 ?c3_patient (?radiologist) ?patient ?physician)

#     ; Patient brings about bAppointmentKept
#     (!performBiopsy ?radiologist ?patient ?physician)

#     ; The above should detach C4
#     (testCommitment C5 ?c5_patient (?patient) detached)

#     ; The above should satisfy G11 and C3
#     (testGoal G11 G11 (?patient) satisfied)
#     (testcommitment C3 ?c3_patient (?radiologist) satisfied)
#   )
# )

def step3(patient)
  physician = ''
  radiologist = ''
  c3_patient = ''
  c5_patient = ''
  generate(
    [
      ['patient', patient],
      ['physician', physician],
      ['radiologist', radiologist],
      ['commitment', C3, c3_patient, patient, physician],
      ['commitment', C5, c5_patient, radiologist, physician]
    ],
    [], physician, radiologist, c3_patient, c5_patient
  ) {
    yield [
      ['consider', G8, G8, radiologist, list(patient)],
      ['activate', G8, G8, radiologist, list(patient)],
      ['entice', G8, G8, list(patient), C5, c5_patient, list(patient), radiologist, physician],
      ['detach', G9, G9, list(patient), C5, c5_patient, list(patient), radiologist, physician],
      ['requestBiopsy', physician, patient, radiologist],
      ['testGoal', G9, G9, list(patient), 'satisfied'],
      ['testCommitment', C3, c3_patient, list(radiologist), 'detached'],
      ['deliver', G11, G11, list(patient), C3, c3_patient, list(radiologist), patient, physician],
      ['performBiopsy', radiologist, patient, physician],
      ['testCommitment', C5, c5_patient, list(patient), 'detached'],
      ['testGoal', G11, G11, list(patient), 'satisfied'],
      ['testCommitment', C3, c3_patient, list(radiologist), 'satisfied']
    ]
  }
end


# (:method (step4 ?patient)
#   (
#     (patient ?patient)
#     (physician ?physician)
#     (radiologist ?radiologist)
#     (pathologist ?pathologist)
#     (commitment C5 ?c5_patient ?radiologist ?physician)
#     (commitment C6 ?c6_patient ?pathologist ?radiologist)
#   )
#   (
#     ;  Pathologist considers and activates goal G12
#     (!consider G12 G12 ?pathologist (?patient) )
#     (!activate G12 G12 ?pathologist (?patient) )

#     ; Pathologist employs ENTICE for G12 to create commitment C6
#     (entice G12 G12 (?patient) C6 C6 (?patient) ?pathologist ?radiologist)

#     ;Radiologist employs DETACH for C6 to consider and activate goal G13
#     (detach G13 G13 (?radiologist) C6 C6 (?patient) ?pathologist ?radiologist)

#     ;Radiologist brings about pathologyRequested and tissueProvided
#     (!performBiopsy ?radiologist ?patient ?physician)
#     (!requestPathologyReport ?physician ?radiologist ?pathologist ?patient)

#     ;The above should satisfy G13 and detach C6
#     (testGoal G13 G13 (?radiologist) satisfied)
#     (testCommitment C6 C6 (?patient) detached)

#     ;Pathologist employs DELIVER for C6 to consider and activate goal G15
#     (deliver G15 G15 (?pathologist) C6 C6 (?patient) ?pathologist ?radiologist)

#     ;Pathologist brings about pathResultsReported
#     (!sendPathologyReport ?radiologist ?physician ?pathologist ?patient)

#     ;The above should satisfy G15 and C6
#     (testGoal G15 G15 (?pathologist) satisfied)
#     (testcommitment C6 C6 (?patient) satisfied)

#     ;Radiologist employs DELIVER for C5 to consider and activate goal G16
#     (deliver G16 G16 (?patient) C5 ?c5_patient (?patient) ?radiologist ?physician)

#     ;Radiologist brings about radPathResultsReported
#     (!sendRadiologyReport ?radiologist ?physician ?patient)
#     (!sendIntegratedReport ?radiologist ?pathologist ?patient ?physician)

#     ;The above should satisfies G16 and C5
#     (testGoal G16 G16 (?patient) satisfied)
#     (testcommitment C5 ?c5_patient (?patient) satisfied)
#   )
# )

def step4(patient)
  physician = ''
  radiologist = ''
  pathologist = ''
  c5_patient = ''
  c6_patient = ''
  generate(
    [
      ['patient', patient],
      ['physician', physician],
      ['radiologist', radiologist],
      ['pathologist', pathologist],
      ['commitment', C5, c5_patient, radiologist, physician],
      ['commitment', C6, c6_patient, pathologist, radiologist],
    ],
    [], physician, radiologist, pathologist, c5_patient, c6_patient
  ) {
    yield [
      ['consider', G12, G12, pathologist, list(patient)],
      ['activate', G12, G12, pathologist, list(patient)],
      ['entice', G12, G12, list(patient), C6, c6_patient, list(patient), pathologist, radiologist],
      ['detach', G13, G13, list(radiologist), C6, c6_patient, list(patient), pathologist, radiologist],
      ['performBiopsy', radiologist, patient, physician],
      ['requestPathologyReport', physician, radiologist, pathologist, patient],
      ['testGoal', G13, G13, list(radiologist), 'satisfied'],
      ['testCommitment', C6, c6_patient, list(patient), 'detached'],
      ['deliver', G15, G15, list(pathologist), C6, c6_patient, list(patient), pathologist, radiologist],
      ['sendPathologyReport', radiologist, physician, pathologist, patient],
      ['testGoal', G15, G15, list(pathologist), 'satisfied'],
      ['testCommitment', C6, c6_patient, list(patient), 'satisfied'],
      ['deliver', G16, G16, list(patient), C5, c5_patient, list(patient), radiologist, physician],
      ['sendRadiologyReport', radiologist, physician, patient],
      ['sendIntegratedReport', radiologist, pathologist, patient, physician],
      ['testGoal', G16, G16, list(patient), 'satisfied'],
      ['testCommitment', C5, c5_patient, list(patient), 'satisfied']
    ]
  }
end

# (:method (step5 ?patient)
#   (
#     (patient ?patient)
#     (pathologist ?pathologist)
#     (registrar ?registrar)
#     (commitment C7 ?c7_patient ?registrar ?pathologist)
#   )
#   (
#     ; Registrar considers and activates goal
#     (!consider G17 G17 ?registrar (?patient) )
#     (!activate G17 G17 ?registrar (?patient) )

#     ; Registrar employs ENTICE for G17 to create commitment C7
#     (entice G17 G17 (?patient) C7 ?c7_patient (?patient) ?registrar ?pathologist)

#     ; Pathologist employs DETACH rule if patient has cancer to consider and activate goal G18
#     (detach G18 G18 (?pathologist) C7 ?c7_patient (?patient) ?registrar ?pathologist)

#     ; Pathologist reports patient to registrar
#     (!reportPatient ?patient ?pathologist ?registrar)

#     ;The above should satisfies G16 and C5
#     (testGoal G17 G17 (?patient) satisfied)
#     (testCommitment C7 ?c7_patient (?patient) detached)

#     ; Registrar employs DELIVER rule for C7 to consider and activate goal G19
#     (deliver G19 G19 (?registrar) C7 ?c7_patient (?patient) ?registrar ?pathologist)

#     ; Registrar brings about addPatientToRegistry. This:
#     (!addPatientToRegistry ?patient ?registrar)

#     ;The above should satisfy G19 and C7
#     (testGoal G19 G19 (?registrar) satisfied)
#     (testCommitment C7 ?c7_patient (?patient) satisfied)
#   )
# )

def step5(patient)
  physician = ''
  pathologist = ''
  registrar = ''
  c7_patient = ''
  generate(
    [
      ['patient', patient],
      ['pathologist', pathologist],
      ['registrar', registrar],
      ['commitment', C7, c7_patient, registrar, pathologist]
    ],
    [], pathologist, registrar, c7_patient
  ) {
    yield [
      ['consider', G17, G17, registrar, list(patient)],
      ['activate', G17, G17, registrar, list(patient)],
      ['entice', G17, G17, list(patient), C7, c7_patient, list(patient), registrar, pathologist],
      ['detach', G18, G18, list(pathologist), C7, c7_patient, list(patient), registrar, pathologist],
      ['reportPatient', patient, pathologist, registrar],
      ['testGoal', G17, G17, list(patient) ,'satisfied'],
      ['testCommitment', C7, c7_patient, list(patient), 'detached'],
      ['deliver', G19, G19, list(registrar), C7, c7_patient, list(patient), registrar, pathologist],
      ['addPatientToRegistry', patient, registrar],
      ['testGoal', G19, G19, list(registrar), 'satisfied'],
      ['testCommitment', C7, c7_patient, list(patient), 'satisfied']
    ]
  }
end