puts 'Single plan'
1.upto(5) {|i|
  puts "#{i} of 5"
  max_plans    = 1
  min_prob     = 0
  patients     = i * 5
  physicians   = i
  radiologists = i
  pathologists = i
  registrars   = i
  hospitals    = i
  cancers      = i
  output = `ruby pbgenerator.rb -max_plans #{max_plans} -min_prob #{min_prob} -patients #{patients} -physicians #{physicians} -radiologists #{radiologists} -pathologists #{pathologists} -registrars #{registrars} -hospitals #{hospitals} -cancers #{cancers}`
  IO.write("pbgenerator#{i}_single_plan.txt", output)
}

puts 'All plans'
1.upto(5) {|i|
  puts "#{i} of 5"
  max_plans    = -1
  min_prob     = 0
  patients     = i * 5
  physicians   = i
  radiologists = i
  pathologists = i
  registrars   = i
  hospitals    = i
  cancers      = i
  output = `ruby pbgenerator.rb -max_plans #{max_plans} -min_prob #{min_prob} -patients #{patients} -physicians #{physicians} -radiologists #{radiologists} -pathologists #{pathologists} -registrars #{registrars} -hospitals #{hospitals} -cancers #{cancers}`
  IO.write("pbgenerator#{i}_all_plans.txt", output)
}