#!/usr/bin/env ruby

DATABASE = ARGV[0] || 'test.gz' # database. must be compressed fasta format
CORES = 2 # number of CPUs to use
SEED = 42 # random seed

# here's where you define how the experiment is run

sample_sizes = [10, 20, 30]
ranges = [
  [0, 100],
  [200, 300],
  [500, 600],
  [600, 700],
  [700, 800],
  [800, 900],
  [900, 1000]
]

bootstraps = 100

# this is ugly:
['dnaio', 'misc']
.each { |x| require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', x )) }

require 'zlib'
require 'bio'
require 'command_line_reporter'

class Experiment
  include CommandLineReporter
  
  def initialize(args={})
    @sample_size = args[:sample_size]
    @range = args[:range]
    @start, @stop = @range
    @out_folder = args[:out_folder]
    @database = args[:database]
    self.formatter = 'nested'
    
    `mkdir -p #{@out_folder}`
    
    self.run
  end
  
  def run
    
    report(:message => 'creating subset of database', :complete => 'subset saved') do
      r = make_subset(
        :sample_size => @sample_size,
        :start => @start, 
        :stop => @stop,
        :out_folder => @out_folder,
        :database => @database)
      if r == nil
        report :message => 'skipping range due to empty record'
        next
      end
    end
    
    # align full and truncated data subset
    report(:message => 'computing alignment', :complete => 'alignment computed') do
      ['full', 'truncated'].each do |f|
        
        run_alignment(
          :in => "#{@out_folder}/#{f}.fasta",
          :out => "#{@out_folder}/#{f}.aligned.fasta"
        )
        
        convert_alignment(
          :in => "#{@out_folder}/#{f}.aligned.fasta",
          :out => "#{@out_folder}/#{f}.aligned.phy"
        )
      end
    end
    
    # compute the GTRCAT ML tree using RAxML
    report(:message => 'phylogenetic inference', :complete => 'tree computed') do
      ['full', 'truncated'].each do |f|
        report(:message => "compute #{f} tree") do
          `bin/raxml -p #{SEED} -m GTRGAMMAI -n #{f} -T #{CORES} -s #{@out_folder}/#{f}.aligned.phy > #{@out_folder}/raxml.log`
          sleep 1
          `mv RAxML_bestTree.#{f} #{@out_folder}/#{f}.tree`
          `mv RAxML* #{@out_folder}`
          if $?.to_i != 0
            fail "!! RAXML crashed"
            exit
          end
        end
      end
    end
    
    # compute and record difference between full and truncated tree
    report(:message => 'measuring tree distance') do
      `rm -f outfile`
      `cat #{@out_folder}/truncated.tree #{@out_folder}/full.tree > intree`
      `bin/treedist < treedistargs > /dev/null`
      `cp intree #{@out_folder}/combined_trees.txt`
    
      data = File.read('outfile')
      score = data.match(/Trees 1 and 2:\s*(.*)/).to_a[1]
      score
      
    end  
  end
end

# Load database and keep it in memory
database = load_database(DATABASE)

# begin running experiment
bootstraps.times do |b|
  sample_sizes.each do |sample_size|
    ranges.each do |start, stop|
      
      # create output folder
      out_folder = "out/experiment_#{@b}_#{@sample_size}_#{@start}_#{@stop}"
      
      # compute experiment
      score = Experiment.new(
        :sample_size => sample_size,
        :range => [start, stop],
        :out_folder => out_folder,
        :database => database
      )
      
      # log results
      File.open('results.txt', 'a') do |h|
        h.puts [b, sample_size, start, stop, score].join("\t")
      end
      
    exit
    end
  end
end
