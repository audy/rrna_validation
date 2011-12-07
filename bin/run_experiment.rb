#!/usr/bin/env ruby

DATABASE = ARGV[0] # database. must be compressed fasta format

if DATABASE == nil
  $stderr.puts 'usage: run_experiment <DATABASE>'
  exit
end

CORES = 24 # number of CPUs to use
SEED = 42 # random seed

# here's where you define how the experiment is run

bootstraps = 200
sample_sizes = [25] # do 10 & 50 as well
ranges = %w[
  0-100
  50-150
  100-200
  150-250
  200-300
  250-350
  300-400
  350-450
  400-500
  450-550
  500-600
  550-650
  600-700
  650-750
  700-800
  750-850
  800-900
  850-950
].collect{ |x| x = x.split('-').collect { |x| x.to_i }}



# this is ugly:
['dnaio', 'misc', 'experiment']
.each { |x| require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', x )) }

# Load database and keep it in memory
puts "loading database... this takes a while"
database = load_database(DATABASE)

out = File.open('results.txt', 'a')
out.puts('n,b,sample_size,start,stop,treedist')
n = 0

# begin running experiment
bootstraps.times do |b|
  sample_sizes.each do |sample_size|
    # create output folder
    n += 1
    
    # load database
    experiment = Experiment.new :database => database, :sample_size => sample_size
    experiment.get_subset!
    
    # compute score for a bunch of ranges
    ranges.each do |start, stop|
      
      out_folder = "out/#{n}_#{b}_#{sample_size}_#{start}_#{stop}"
      
      puts out_folder
      
      next if File.exist?("#{out_folder}/combined_trees.txt")
      
      # hack!
      `mkdir -p #{out_folder}`
      if File.exist?('full.tree')
        `cp full.tree #{out_folder}/full.tree`
      end
      
      # create an experiment and run
      score = experiment.setup!(
        :start => start,
        :stop => stop,
        :out_folder => out_folder,
      ).run!
      
      # hack!
      if File.exist?("#{out_folder}/full.tree")
        `mv #{out_folder}/full.tree .`
      end
      
      # log result
      out.puts [n, b, sample_size, start, stop, score].join(",") unless score.nil?
      puts [n, b, sample_size, start, stop, score].join(",") unless score.nil?

    end # ranges
    `rm -rf full.tree`
  end # sample_sizes
end # bootstraps

