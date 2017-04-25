jshop_output = ARGV.first == 'jshop'

puts 'Single plan'
1.upto(25) {|patients|
  t = Time.now.to_f
  puts "#{patients} of 25", Time.now
  max_plans  = 1
  min_prob   = 0
  physicians = radiologists = pathologists = registrars = hospitals = cancers = (patients - 1) / 5 + 1
  if jshop_output
    output = `ruby pbgenerator.rb -max_plans #{max_plans} -min_prob #{min_prob} -patients #{patients} -physicians #{physicians} -radiologists #{radiologists} -pathologists #{pathologists} -registrars #{registrars} -hospitals #{hospitals} -cancers #{cancers}`
    IO.write("pbgenerator#{patients}_single_plan.txt", output)
  else
    `ruby pbgenerator.rb -max_plans #{max_plans} -min_prob #{min_prob} -patients #{patients} -physicians #{physicians} -radiologists #{radiologists} -pathologists #{pathologists} -registrars #{registrars} -hospitals #{hospitals} -cancers #{cancers} -jshop`
  end
  puts "#{Time.now.to_f - t}s"
}

puts 'All plans'
1.upto(25) {|patients|
  t = Time.now.to_f
  puts "#{patients} of 25", Time.now
  max_plans  = -1
  min_prob   = 0
  physicians = radiologists = pathologists = registrars = hospitals = cancers = (patients - 1) / 5 + 1
  if jshop_output
    output = `ruby pbgenerator.rb -max_plans #{max_plans} -min_prob #{min_prob} -patients #{patients} -physicians #{physicians} -radiologists #{radiologists} -pathologists #{pathologists} -registrars #{registrars} -hospitals #{hospitals} -cancers #{cancers}`
    IO.write("pbgenerator#{patients}_all_plans.txt", output)
  else
    `ruby pbgenerator.rb -max_plans #{max_plans} -min_prob #{min_prob} -patients #{patients} -physicians #{physicians} -radiologists #{radiologists} -pathologists #{pathologists} -registrars #{registrars} -hospitals #{hospitals} -cancers #{cancers}`
  end
  puts "#{Time.now.to_f - t}s"
}