jshop_output = ARGV[0] == 'jshop'

def plan(file, max_plans, min_prob, patients, n)
  File.binwrite(file, `ruby pbgenerator.rb -max_plans #{max_plans} -min_prob #{min_prob} -patients #{patients} -physicians #{n} -radiologists #{n} -pathologists #{n} -registrars #{n} -hospitals #{n} -cancers #{n}`)
end

puts 'Single plan'
max_plans = 1
min_prob  = 0
1.upto(21) {|patients|
  n = (patients - 1) / 5 + 1
  1.times {|j|
    puts "#{patients} of 21", Time.now
    t = Time.now.to_f
    if jshop_output
      puts `ruby pbgenerator.rb -max_plans #{max_plans} -min_prob #{min_prob} -patients #{patients} -physicians #{n} -radiologists #{n} -pathologists #{n} -registrars #{n} -hospitals #{n} -cancers #{n} -jshop pb#{patients}.jshop`
    else
      plan("pbgenerator#{patients}_single_plan_#{j}.txt", max_plans, min_prob, patients, n)
    end
    puts "#{Time.now.to_f - t}s"
  }
}
exit if jshop_output

puts 'All plans'
max_plans = -1
min_prob  = 0
1.upto(21) {|patients|
  n = (patients - 1) / 5 + 1
  puts "#{patients} of 21", Time.now
  t = Time.now.to_f
  plan("pbgenerator#{patients}_all_plans.txt", max_plans, min_prob, patients, n)
  puts "#{Time.now.to_f - t}s"
}