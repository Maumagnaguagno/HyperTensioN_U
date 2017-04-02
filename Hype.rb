#!/usr/bin/env ruby
#-----------------------------------------------
# Hype
#-----------------------------------------------
# Mau Magnaguagno
#-----------------------------------------------
# Planning description converter
#-----------------------------------------------

require_relative 'UJSHOP_Parser'
require_relative 'UHyper_Compiler'

module Hype
  extend self

  attr_reader :parser

  HELP = "  Usage:
    Hype domain problem [output] [max plans=-1(all)] [min probability=0]\n
  Output:
    rb    - generate Ruby files to Hypertension U(default)
    run   - same as rb with execution
    debug - same as run with execution log"

  #-----------------------------------------------
  # Parse
  #-----------------------------------------------

  def parse(domain, problem)
    raise 'Incompatible extensions between domain and problem' if File.extname(domain) != File.extname(problem)
    @parser = UJSHOP_Parser
    @parser.parse_domain(domain)
    @parser.parse_problem(problem)
  end

  #-----------------------------------------------
  # Compile
  #-----------------------------------------------

  def compile(domain, problem)
    raise 'No data to compile' unless @parser
    compiler = UHyper_Compiler
    args = [
      @parser.domain_name,
      @parser.problem_name,
      @parser.operators,
      @parser.methods,
      @parser.predicates,
      @parser.state,
      @parser.tasks,
      @parser.axioms,
      @parser.reward
    ]
    data = compiler.compile_domain(*args)
    IO.write("#{domain}.rb", data) if data
    data = compiler.compile_problem(*args << File.basename(domain))
    IO.write("#{problem}.rb", data) if data
  end
end

#-----------------------------------------------
# Main
#-----------------------------------------------
if $0 == __FILE__
  begin
    if ARGV.size < 2 or ARGV.first == '-h'
      puts Hype::HELP
    else
      domain = ARGV.shift
      problem = ARGV.shift
      type = ARGV.shift
      if not File.exist?(domain)
        puts "Domain file #{domain} not found"
      elsif not File.exist?(problem)
        puts "Problem file #{problem} not found"
      else
        t = Time.now.to_f
        Hype.parse(domain, problem)
        Hype.compile(domain, problem)
        require File.expand_path(problem) if type == 'run' or (type == 'debug' and ARGV[0] = '-d')
        puts "Total time: #{Time.now.to_f - t}s"
      end
    end
  rescue
    puts $!, $@
  end
end