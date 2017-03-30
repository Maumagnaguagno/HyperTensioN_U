# Healthcare

### Predicates
- ``(patient ?patient)``
- ``(physician ?physician)``
- ``(radiologist ?radiologist)``
- ``(pathologist ?pathologist)``
- ``(registrar ?registrar)``
- ``(hospital ?hospital)``
- ``(patientHasCancer ?patient)``
- ``(commitment ?c ?ci ?de ?cr)``
- ``(var ?g ?gi (?t))``
- ``(varG ?g ?gi ?gv)``
- ``(diagnosisRequested ?patient ?physician)``
- ``(iAppointmentRequested ?patient ?radiologist)``
- ``(iAppointmentKept ?patient ?radiologist)``
- ``(imagingScan ?patient ?physician)``
- ``(imagingRequested ?physician ?patient)``
- ``(imagingResultsReported ?radiologist ?physician ?patient)``
- ``(bAppointmentRequested ?patient ?pathologist)``
- ``(bAppointmentKept ?patient ?pathologist)``
- ``(biopsyReport ?patient ?physician)``
- ``(biopsyRequested ?physician ?patient)``
- ``(radiologyRequested ?physician ?radiologist ?patient)``
- ``(treatmentPlan ?physician ?patient)``
- ``(diagnosisProvided ?physician ?patient)``
- ``(tissueProvided ?patient)``
- ``(radPathResultsReported ?radiologist ?physician ?patient)``
- ``(pathResultsReported ?pathologist ?physician ?patient)``
- ``(patientReportedToRegistrar ?patient ?registrar)``
- ``(inRegistry ?patient)``
- ``(pathologyRequested ?physician ?pathologist ?patient)``
- ``(integratedReport ?patient ?physician)``
- ``(reportNeedsReview ?patient ?pathologist)``
- ``(cancelled ?c ?ci ?cv)``
- ``(released ?c ?ci ?cv)``
- ``(expired ?c ?ci ?cv)``
- ``(dropped ?g ?gi ?gv)``
- ``(aborted ?g ?gi ?gv)``
- ``(pending ?c ?ci ?cv)``
- ``(activatedG ?g ?gi ?gv)``
- ``(suspendedG ?g ?gi ?gv)``
- ``(goal ?g ?gi ?a)``
- ``(dontknow ?patient)``

### Axioms
[Equality axioms](equality-axioms.rb)
- ``(eqGSCP ?g ?gv ?c ?cv)``
- ``(eqGSCQ ?g ?gv ?c ?cv)``
- ``(eqCPCQ ?c1 ?cv1 ?c2 ?cv2)``

[Commitment axioms](commitment-axioms.rb)
- ``(null ?c ?ci ?cv)``
- ``(conditional ?c ?ci ?cv)``
- ``(detached ?c ?ci ?cv)``
- ``(active ?c ?ci ?cv)``
- ``(terminated ?c ?ci ?cv)``
- ``(violated ?c ?ci ?cv)``
- ``(satisfied ?c ?ci ?cv)``
- ``(terminal ?c ?ci ?cv)``

[Healthcare axioms](healthcare-axioms.rb)
- ``(p  ?c CN (?t))``
- ``(q  ?c CN (?t))``
- ``(pg ?g GN (?t))``
- ``(s  ?g GN (?t))``
- ``(f  ?g GN (?t))``

[Goal axioms](goal-axioms.rb)
- ``(nullG ?g ?gi ?gv)``
- ``(inactiveG ?g ?gi ?gv)``
- ``(activeG ?g ?gi ?gv)``
- ``(satisfiedG ?g ?gi ?gv)``
- ``(failedG ?g ?gi ?gv)``
- ``(terminatedG ?g ?gi ?gv)``
- ``(terminalG ?g ?gi ?gv)``

[Goal commitment methods, added for readbility, used by method negotiate](goal-commitment-methods.rb)
- ``(negotiable ?g ?gi ?gv ?c ?ci ?cv)``

### Operators
[commitment operators](commitment-operators.rb)
- ``(!!testSuccess ?c ?ci ?cv ?state)``
- ``(!!testFailure ?cg ?state)``
- ``(!create ?c ?ci ?de ?cr ?cv)``
- ``(!suspend ?c ?ci ?de ?cr ?cv)``
- ``(!reactivate ?c ?ci ?de ?cr ?cv)``
- ``(!expire ?c ?ci ?de ?cr ?cv)``
- ``(!timeoutviolate ?c ?ci ?de ?cr ?cv)``
- ``(!cancel ?c ?ci ?de ?cr ?cv)``
- ``(!release ?c ?ci ?de ?cr ?cv)``

[Goal operators](goal-operators.rb)
- ``(!!testSuccessG ?g ?gi ?gv ?state)``
- ``(!consider ?g ?gi ?a ?gv)``
- ``(!activate ?g ?gi ?a ?gv)``
- ``(!suspendG ?gi ?a ?gv)``
- ``(!reconsider ?g ?gi ?a ?gv)``
- ``(!reactivateG ?gi ?a ?gv)``
- ``(!drop ?g ?gi ?a ?gv)``
- ``(!abort ?g ?gi ?a ?gv)``

[Healthcare operators](healthcare-operators.rb)
- ``(!requestAssessment ?patient ?physician)``
- ``(!requestImaging ?physician ?patient ?radiologist)``
- ``(!requestBiopsy ?physician ?patient ?pathologist)``
- ``(!performImaging ?radiologist ?patient ?physician)``
- ``(!performBiopsy ?radiologist ?patient ?physician)``
- ``(!requestPathologyReport ?physician ?radiologist ?patient)``
- ``(!requestRadiologyReport ?physician ?radiologist ?patient)``
- ``(!sendPathologyReport ?radiologist ?physician ?patient)``
- ``(!sendRadiologyReport ?radiologist ?physician ?patient)``
- ``(!sendIntegratedReport ?radiologist ?pathologist ?patient ?physician)``
- ``(!generateTreatmentPlan ?physician ?patient)``
- ``(!reportPatient ?patient ?pathologist ?registrar)``
- ``(!addPatientToRegistry ?patient ?registrar)``
- ``(!escalateFailure ?patient ?physician ?radiologist ?hospital)``
- ``(!requestPhysicianReportAssessment ?patient ?physician ?hospital)``
- ``(!requestRadiologyReportAssessment ?pathologist ?radiologist ?patient ?hospital)``
- ``(!requestPathologyReportAssessment ?radiologist ?pathologist ?patient ?hospital)``

### Methods
[Goal methods](goal-methods.rb)
- ``(achieveGoals)``
- ``(achieveGoal C1 ?gi C2)``

[Goal and commitment methods](goal-commitment-methods.rb)
- ``(entice ?g ?gi ?gv ?c ?ci ?cv ?d ?a)``
- ``(suspendOffer ?g ?gi ?gv ?c ?ci ?cv ?d ?a)``
- ``(revive ?g ?gi ?gv ?c ?ci ?cv ?d ?a)``
- ``(withdrawOffer ?g ?gi ?gv ?c ?ci ?cv ?d ?a)``
- ``(reviveToWithdraw ?g ?gi ?gv ?c ?ci ?cv ?d ?a)``
- ``(negotiate ?g ?gi ?gv ?c1 ?ci1 ?cv1 ?c2 ?ci2 ?cv2 ?d ?a1 ?a2)``
- ``(abandonEndGoal ?g ?gi ?gv ?c ?ci ?cv ?d ?a)``
- ``(deliver ?g ?gi ?gv ?c ?ci ?cv ?d ?a)``
- ``(detach ?g ?gi ?gv ?c ?ci ?cv ?d ?a)``
- ``(backBurner ?g ?gi ?gv ?c ?ci ?cv ?d ?a)``
- ``(frontBurner ?g ?gi ?gv ?c ?ci ?cv ?d ?a)``
- ``(abandonMeansGoal ?g ?gi ?gv ?c ?ci ?cv ?d ?a)``
- ``(persist ?g ?gi ?gv ?c ?ci ?cv ?g2 ?gi2 ?gv2 ?d ?a)``
- ``(giveUp ?g ?gi ?gv ?c ?ci ?cv ?d ?a)``

[Test methods](test-methods.rb)
- ``(testCommitment ?c ?ci ?cv ?s)``
- ``(testGoal ?g ?gi ?gv ?s)``
- ``(testGoalCommitmentRule ?rule ?g ?gi ?a ?c ?ci ?de ?cr)``

[Healthcare methods](healthcare-methods.rb)
- ``(hospitalScenario)``
- ``(testCommitments)``
- ``(seekHelp ?patient)``
- ``(processPatient ?patient)``
- ``(performImagingTests ?patient)``
- ``(performPathologyTests ?patient)``
- ``(attendTest ?patient)``
- ``(deliverDiagnostics ?patient)``