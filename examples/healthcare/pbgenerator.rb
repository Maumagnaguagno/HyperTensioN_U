#!/usr/bin/env ruby
require_relative 'healthcare'

# Help
if ARGV.include?('-h')
  puts "  Usage:
    pbgenerator [-d] [-option arg]\n
  Options:
    -d            - debug mode
    -min_prob     - Minimum probability to include plan (default 0)
    -max_plans    - Maximum amount of plans to search (default 1)
    -patients     - Amount of patients (default 1)
    -physicians   - Amount of physicians (default 1)
    -radiologists - Amount of radiologists (default 1)
    -pathologists - Amount of pathologists (default 1)
    -registrars   - Amount of registrars (default 1)
    -hospitals    - Amount of hospitals (default 1)
    -cancers      - Amount of patients with cancer (default 1)"
  exit
end

# Default values
debug = false
min_probability = 0
max_plans_found = 1
patients     = 1
physicians   = 1
radiologists = 1
pathologists = 1
registrars   = 1
hospitals    = 1
cancers      = 1

# ARGV parser
while opt = ARGV.shift
  case opt
  when '-d' then debug = true
  when '-min_prob' then min_probability = ARGV.shift.to_f
  when '-max_plans' then max_plans_found = ARGV.shift.to_i
  when '-patients' then patients = ARGV.shift.to_i
  when '-physicians' then physicians = ARGV.shift.to_i
  when '-radiologists' then radiologists = ARGV.shift.to_i
  when '-pathologists' then pathologists = ARGV.shift.to_i
  when '-registrars' then registrars = ARGV.shift.to_i
  when '-hospitals' then hospitals = ARGV.shift.to_i
  when '-cancers' then cancers = ARGV.shift.to_i
  else raise "Unknown option: #{opt}"
  end
end

# Objects
C1 = 'C1'
C2 = 'C2'
C3 = 'C3'
C4 = 'C4'
C5 = 'C5'
C6 = 'C6'
C7 = 'C7'
C8 = 'C8'

PATIENT_SET     = Array.new(patients)     {|i| "patient_#{i}"}
PHYSICIAN_SET   = Array.new(physicians)   {|i| "physician_#{i}"}
RADIOLOGIST_SET = Array.new(radiologists) {|i| "radiologist_#{i}"}
PATHOLOGIST_SET = Array.new(pathologists) {|i| "pathologist_#{i}"}
REGISTRAR_SET   = Array.new(registrars)   {|i| "registrar_#{i}"}
HOSPITAL_SET    = Array.new(hospitals)    {|i| "hospital_#{i}"}

# Expand commitment permutations
COMMITMENT_SET = []
PHYSICIAN_SET.each {|physician|
  PATIENT_SET.each {|patient|
    COMMITMENT_SET.push(
      [C1, C1, physician, patient],
      [C2, C2, patient, physician],
      [C3, C3, patient, physician]
    )
  }
  RADIOLOGIST_SET.each {|radiologist|
    COMMITMENT_SET.push(
      [C4, C4, radiologist, physician],
      [C5, C5, radiologist, physician]
    )
  }
}
RADIOLOGIST_SET.each {|radiologist|
  PATHOLOGIST_SET.each {|pathologist|
    COMMITMENT_SET << [C6, C6, pathologist, radiologist]
  }
}
HOSPITAL_SET.each {|hospital|
  PATHOLOGIST_SET.each {|pathologist|
    COMMITMENT_SET << [C7, C7, pathologist, hospital]
  }
  REGISTRAR_SET.each {|registrar|
    COMMITMENT_SET << [C8, C8, registrar, hospital]
  }
}

Healthcare.problem(
  # Start
  {
    'patient' => PATIENT_SET.map {|i| [i]},
    'physician' => PHYSICIAN_SET.map {|i| [i]},
    'radiologist' => RADIOLOGIST_SET.map {|i| [i]},
    'pathologist' => PATHOLOGIST_SET.map {|i| [i]},
    'registrar' => REGISTRAR_SET.map {|i| [i]},
    'hospital' => HOSPITAL_SET.map {|i| [i]},
    'patientHasCancer' => PATIENT_SET.first(cancers).map {|i| [i]},
    'commitment' => COMMITMENT_SET,
    'var' => [],
    'diagnosisRequested' => [],
    'iAppointmentRequested' => [],
    'iAppointmentKept' => [],
    'imagingScan' => [],
    'imagingRequested' => [],
    'imagingResultsReported' => [],
    'bAppointmentRequested' => [],
    'bAppointmentKept' => [],
    'biopsyReport' => [],
    'biopsyRequested' => [],
    'radiologyRequested' => [],
    'treatmentPlan' => [],
    'diagnosisProvided' => [],
    'tissueProvided' => [],
    'radPathResultsReported' => [],
    'pathResultsReported' => [],
    'patientReportedToRegistrar' => [],
    'inRegistry' => [],
    'TBAgreesPath' => [],
    'TBDisagreesPath' => [],
    'TBAgreesRad' => [],
    'TBDisagreesRad' => [],
    'TBAgreesPCP' => [],
    'TBDisagreesPCP' => [],
    'pathologyRequested' => [],
    'escalate' => [],
    'radRequestsAssessment' => [],
    'phyRequestsAssessment' => [],
    'patRequestsAssessment' => [],
    'integratedReport' => [],
    'reportNeedsReview' => [],
    'cancelled' => [],
    'released' => [],
    'expired' => []
  },
  # Tasks
  [['hospitalScenario']],
  # Debug
  debug,
  # Minimal probability for plans
  min_probability,
  # Maximum plans found
  max_plans_found
)