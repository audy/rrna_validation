#!/usr/bin/env ruby

DATABASE = ARGV[0] || 'database.gz'
CORES = 2

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

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'dnaio'))
require 'zlib'
require 'bio'

# Load database and keep it in memory
puts "loading database... this may take a while"
database = load_database(DATABASE)
puts "loaded #{database.length} records"


# begin running experiment
puts "commencing science!"
bootstraps.times do |b|
  sample_sizes.each do |sample_size|
    ranges.each do |start, stop|
      
      puts [b, sample_size, start, stop].join("\t")
      
      # create output folder
      out_folder = "experiment_#{b}_#{sample_size}_#{start}_#{stop}"
      `mkdir -p #{out_folder}`
      
      # create a random subset of the database
      # including the truncated sequence file
      puts "creating subset"
      r = make_subset(
        :sample_size => sample_size,
        :start => start, 
        :stop => stop,
        :out_folder => out_folder,
        :database => database)
      if r == nil
        puts "skipping range"
        next
      end
      
      # align full and truncated data subset
      ['full', 'truncated'].each do |f|
        run_alignment :in => "#{out_folder}/#{f}.fasta", :out => "#{out_folder}/#{f}.aligned.fasta"
      end
      
      # convert full and truncated alignments to Phylip format
      puts "converting alignments to phylip"
      ['full', 'truncated'].each do |f|
        convert_alignment :in => "#{out_folder}/#{f}.aligned.fasta", :out => "#{out_folder}/#{f}.aligned.phy"
      end
      
      # compute the GTRCAT ML tree using RAxML
      ['full', 'truncated'].each do |f|
        puts "computing #{f} tree"
        `bin/raxml -m GTRCAT -n #{f} -T #{CORES} -s #{out_folder}/#{f}.phy > #{out_folder}/raxml.log`
        sleep 1
        `mv RAxML_bestTree.#{f} #{out_folder}/#{f}.tree`
        `mv RAxML* #{out_folder}`
        if $?.to_i != 0
          puts "RAXML crashed!!!"
        end
      end
      
      # compute and record difference between full and truncated tree
      puts "computing tree difference"
      
      `rm -f outfile`
      `cat #{out_folder}/truncated.tree #{out_folder}/full.tree > intree`
      `bin/treedist < treedistargs > /dev/null`
      `cp intree #{out_folder}/combined_trees.txt`
      
      data = File.read('outfile')
      score = data.match(/Trees 1 and 2:\s*(.*)/).to_a[1]
      puts "difference is: #{score}"
      
      File.open('results.txt', 'a') do |h|
        h.puts [b, sample_size, start, stop, score].join("\t")
      end
    
    end
  end
end
