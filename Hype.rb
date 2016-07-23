#!/usr/bin/env ruby
#-----------------------------------------------
# Hype
#-----------------------------------------------
# Mau Magnaguagno
#-----------------------------------------------
# Planning description converter
#-----------------------------------------------

require_relative 'NDJSHOP_Parser'
require_relative 'Hyper_ND_Compiler'

module Hype
  extend self

  attr_reader :parser

  HELP = "  Usage:
    Hype domain problem output\n
  Output:
    rb    - generate Ruby files to Hypertension ND(default)
    run   - same as rb with execution
    debug - same as run with execution log"

  #-----------------------------------------------
  # Parse
  #-----------------------------------------------

  def parse(domain, problem)
    if File.extname(domain) == '.ndjshop' and File.extname(problem) == '.ndjshop'
      @parser = NDJSHOP_Parser
      @parser.parse_domain(domain)
      @parser.parse_problem(problem)
    else raise "Unknown file extension #{File.extname(domain)}"
    end
  end

  #-----------------------------------------------
  # Compile
  #-----------------------------------------------

  def compile(domain, problem, type)
    raise 'No data to compile' unless @parser
    if type == 'rb'
      compiler = Hyper_ND_Compiler
      args = [
        @parser.domain_name,
        @parser.problem_name,
        @parser.operators,
        @parser.methods,
        @parser.predicates,
        @parser.state,
        @parser.tasks,
        @parser.goal_pos,
        @parser.goal_not,
        @parser.reward
      ]
      data = compiler.compile_domain(*args)
      IO.write("#{domain}.#{type}", data) if data
      data = compiler.compile_problem(*args << File.basename(domain))
      IO.write("#{problem}.#{type}", data) if data
    else raise "Unknown type #{type}"
    end
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
        Hype.compile(domain, problem, 'rb')
        if type == 'run' or (type == 'debug' and ARGV[0] = '-d')
          require File.expand_path(problem)
        end
        puts "Total time: #{Time.now.to_f - t}s"
      end
    end
  rescue
    puts $!, $@
  end
end