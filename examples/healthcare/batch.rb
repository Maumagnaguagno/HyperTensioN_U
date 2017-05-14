jshop_output = ARGV.first == 'jshop'

def plan(file, max_plans, min_prob, patients, n)
  IO.write(file, `ruby pbgenerator.rb -max_plans #{max_plans} -min_prob #{min_prob} -patients #{patients} -physicians #{n} -radiologists #{n} -pathologists #{n} -registrars #{n} -hospitals #{n} -cancers #{n}`)
end

puts 'Single plan'
1.upto(21) {|patients|
  10.times {|j|
    t = Time.now.to_f
    puts "#{patients} of 21", Time.now
    max_plans = 1
    min_prob  = 0
    n = (patients - 1) / 5 + 1
    if jshop_output
      o = `ruby pbgenerator.rb -max_plans #{max_plans} -min_prob #{min_prob} -patients #{patients} -physicians #{n} -radiologists #{n} -pathologists #{n} -registrars #{n} -hospitals #{n} -cancers #{n} -jshop pb#{patients}.jshop`
      puts o
    else
      plan("pbgenerator#{patients}_single_plan_#{j}.txt", max_plans, min_prob, patients, n)
    end
    puts "#{Time.now.to_f - t}s"
  }
}
exit if jshop_output

puts 'All plans'
1.upto(21) {|patients|
  t = Time.now.to_f
  puts "#{patients} of 21", Time.now
  max_plans = -1
  min_prob  = 0
  n = (patients - 1) / 5 + 1
  plan("pbgenerator#{patients}_all_plans.txt", max_plans, min_prob, patients, n)
  puts "#{Time.now.to_f - t}s"
}