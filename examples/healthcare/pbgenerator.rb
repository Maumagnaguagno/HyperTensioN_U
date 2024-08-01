#!/usr/bin/env ruby
require_relative 'healthcare'

# Help
if ARGV.include?('-h')
  puts "  Usage:
    pbgenerator [-option [arg]]\n
  Options:
    debug         - debug mode
    -jshop        - JSHOP file output
    -max_plans    - maximum amount of plans to search (default 1)
    -min_prob     - minimum probability to include plan (default 0)
    -patients     - amount of patients (default 1)
    -physicians   - amount of physicians (default 1)
    -radiologists - amount of radiologists (default 1)
    -pathologists - amount of pathologists (default 1)
    -registrars   - amount of registrars (default 1)
    -hospitals    - amount of hospitals (default 1)
    -cancers      - amount of patients with cancer (default 1)"
  exit
end

# Default values
debug = false
jshop = nil
max_plans    = 1
min_prob     = 0
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
  when 'debug' then debug = true
  when '-jshop' then jshop = "#{__dir__}/#{ARGV.shift}"
  when '-min_prob' then min_prob = ARGV.shift.to_f
  when '-max_plans' then max_plans = ARGV.shift.to_i
  when '-patients' then patients = ARGV.shift.to_i
  when '-physicians' then physicians = ARGV.shift.to_i
  when '-radiologists' then radiologists = ARGV.shift.to_i
  when '-pathologists' then pathologists = ARGV.shift.to_i
  when '-registrars' then registrars = ARGV.shift.to_i
  when '-hospitals' then hospitals = ARGV.shift.to_i
  when '-cancers' then cancers = ARGV.shift.to_i
  else abort("Unknown option: #{opt}")
  end
end

# Objects
PATIENT_SET     = Array.new(patients)     {|i| "patient_#{i}"}
PHYSICIAN_SET   = Array.new(physicians)   {|i| "physician_#{i}"}
RADIOLOGIST_SET = Array.new(radiologists) {|i| "radiologist_#{i}"}
PATHOLOGIST_SET = Array.new(pathologists) {|i| "pathologist_#{i}"}
REGISTRAR_SET   = Array.new(registrars)   {|i| "registrar_#{i}"}
HOSPITAL_SET    = Array.new(hospitals)    {|i| "hospital_#{i}"}

# Expand commitment permutations
COMMITMENT_SET = []
PATIENT_SET.each {|patient|
  PHYSICIAN_SET.each {|physician|
    COMMITMENT_SET.push(
      [C1, "#{C1}_#{patient}", physician, patient],
      [C2, "#{C2}_#{patient}", patient, physician],
      [C3, "#{C3}_#{patient}", patient, physician]
    )
    RADIOLOGIST_SET.each {|radiologist|
      COMMITMENT_SET.push(
        [C4, "#{C4}_#{patient}", radiologist, physician],
        [C5, "#{C5}_#{patient}", radiologist, physician]
      )
    }
  }
  PATHOLOGIST_SET.each {|pathologist|
    RADIOLOGIST_SET.each {|radiologist|
      COMMITMENT_SET << [C6, "#{C6}_#{patient}", pathologist, radiologist]
    }
    REGISTRAR_SET.each {|registrar|
      COMMITMENT_SET << [C7, "#{C7}_#{patient}", registrar, pathologist]
    }
  }
}

# Expand goal permutations
GOAL_SET = []
PATIENT_SET.each {|patient|
  GOAL_SET.push(
    [G2, "#{G2}_#{patient}", patient],
    [G6, "#{G6}_#{patient}", patient],
    [G11, "#{G11}_#{patient}", patient]
  )
}
PHYSICIAN_SET.each {|physician|
  GOAL_SET.push(
    [G1, "#{G1}_#{physician}", physician],
    [G4, "#{G4}_#{physician}", physician],
    [G9, "#{G9}_#{physician}", physician]
  )
}
RADIOLOGIST_SET.each {|radiologist|
  GOAL_SET.push(
    [G3, "#{G3}_#{radiologist}", radiologist],
    [G7, "#{G7}_#{radiologist}", radiologist],
    [G8, "#{G8}_#{radiologist}", radiologist],
    [G13, "#{G13}_#{radiologist}", radiologist],
    [G16, "#{G16}_#{radiologist}", radiologist]
  )
}
PATHOLOGIST_SET.each {|pathologist|
  GOAL_SET.push(
    [G12, "#{G12}_#{pathologist}", pathologist],
    [G15, "#{G15}_#{pathologist}", pathologist],
    [G18, "#{G18}_#{pathologist}", pathologist]
  )
}
REGISTRAR_SET.each {|registrar|
  GOAL_SET.push(
    [G17, "#{G17}_#{registrar}", registrar],
    [G19, "#{G19}_#{registrar}", registrar]
  )
}

# Create tasks
TASKS = []
PATIENT_SET.each_with_index {|patient,i|
  TASKS.push(
    ['step1', patient],
    ['step2', patient],
    ['step3', patient],
    ['step4', patient]
  )
  TASKS << ['step5', patient] if i < cancers
}

if jshop
  SPACER = '-' * 30
  problem_str = "; Generated by Hype\n(defproblem #{File.basename(jshop, '.jshop')} healthcare\n\n  ;#{SPACER}\n  ; Start\n  ;#{SPACER}\n\n  (\n"
  # Start
  PATIENT_SET.each {|pre| problem_str << "    (patient #{pre})\n"}
  PHYSICIAN_SET.each {|pre| problem_str << "    (physician #{pre})\n"}
  RADIOLOGIST_SET.each {|pre| problem_str << "    (radiologist #{pre})\n"}
  PATHOLOGIST_SET.each {|pre| problem_str << "    (pathologist #{pre})\n"}
  REGISTRAR_SET.each {|pre| problem_str << "    (registrar #{pre})\n"}
  HOSPITAL_SET.each {|pre| problem_str << "    (hospital #{pre})\n"}
  PATIENT_SET.first(cancers).each {|pre| problem_str << "    (patientHasCancer #{pre})\n"}
  COMMITMENT_SET.each {|pre| problem_str << "    (commitment #{pre.join(' ')})\n"}
  GOAL_SET.each {|pre| problem_str << "    (goal #{pre.join(' ')})\n"}
  # Tasks
  problem_str << "  )\n\n  ;#{SPACER}\n  ; Tasks\n  ;#{SPACER}\n\n  (\n"
  TASKS.each {|task| problem_str << "    (#{task.join(' ')})\n"}
  File.binwrite(jshop, problem_str << "  )\n)")
else
  # Start
  STATE = [
    PATIENT_SET.zip, # PATIENT
    PHYSICIAN_SET.zip, # PHYSICIAN
    RADIOLOGIST_SET.zip, # RADIOLOGIST
    PATHOLOGIST_SET.zip, # PATHOLOGIST
    REGISTRAR_SET.zip, # REGISTRAR
    HOSPITAL_SET.zip, # HOSPITAL
    PATIENT_SET.first(cancers).zip, # PATIENTHASCANCER
    COMMITMENT_SET, # COMMITMENT
    GOAL_SET, # GOAL
    [], # VAR
    [], # VARG
    [], # DIAGNOSISREQUESTED
    [], # IAPPOINTMENTREQUESTED
    [], # IAPPOINTMENTKEPT
    [], # IMAGINGSCAN
    [], # IMAGINGREQUESTED
    [], # IMAGINGRESULTSREPORTED
    [], # BAPPOINTMENTREQUESTED
    [], # BAPPOINTMENTKEPT
    [], # BIOPSYREPORT
    [], # BIOPSYREQUESTED
    [], # RADIOLOGYREQUESTED
    [], # TREATMENTPLAN
    [], # DIAGNOSISPROVIDED
    [], # TISSUEPROVIDED
    [], # RADPATHRESULTSREPORTED
    [], # PATHRESULTSREPORTED
    [], # PATIENTREPORTEDTOREGISTRAR
    [], # INREGISTRY
    [], # PATHOLOGYREQUESTED
    [], # INTEGRATEDREPORT
    [], # REPORTNEEDSREVIEW
    [], # CANCELLED
    [], # RELEASED
    [], # EXPIRED
    [], # DROPPED
    [], # ABORTED
    [], # PENDING
    [], # ACTIVATEDG
    [], # SUSPENDEDG
    [] # DONTKNOW
  ]
  # Select planner
  if defined?(Hypertension_U)
    Healthcare.problem(STATE, TASKS, debug, max_plans, min_prob)
  else
    Healthcare.problem(STATE, TASKS, debug)
  end
end