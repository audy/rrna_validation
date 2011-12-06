#!/usr/bin/env ruby

DATABASE = ARGV[0] # database. must be compressed fasta format

if DATABASE == nil
  $stderr.puts 'usage: run_experiment <DATABASE>'
  exit
end

CORES = 24 # number of CPUs to use
SEED = 42 # random seed

# here's where you define how the experiment is run

bootstraps = 50
sample_sizes = [25]
length = 100
ranges = [
  [515, 615],
  [706, 806] ]

# this is ugly:
['dnaio', 'misc', 'experiment']
.each { |x| require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', x )) }

# Load database and keep it in memory
puts "loading database... this takes a while"
database = load_database(DATABASE)

# begin running experiment
bootstraps.times do |b|
  sample_sizes.each do |sample_size|
    ranges.each do |start, stop|
     
      # create output folder
      out_folder = "out/experiment_#{b}_#{sample_size}_#{start}_#{stop}"
      
      # skip if already done
      next if File.exist? "#{out_folder}/combined_trees.txt"

      # compute experiment
      experiment = Experiment.new(
        :sample_size => sample_size,
        :range => [start, stop],
        :out_folder => out_folder,
        :database => database
      )
      
      # log results
      File.open('results.txt', 'a') do |h|
        h.puts [b, sample_size, start, stop, experiment.score].join("\t")
      end
    end
  end
end
