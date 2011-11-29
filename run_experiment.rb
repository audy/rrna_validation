#!/usr/bin/env ruby

DATABASE = 'database.gz'
CORES = 24

sample_sizes = [10, 20, 25, 30, 50]
ranges = [
  [300, 400],
  [400, 500],
  [500, 600],
  [600, 700],
  [700, 800],
  [800, 900],
  [900, 1000]
]
sample_sizes = [10]
ranges = [[100, 200]]
bootstraps = 100

require 'zlib'
require 'bio'
require File.expand_path(File.join(File.dirname(__FILE__), '.', 'lib', 'dnaio'))

def load_database(filename)
  handle = File.open(filename)
  uncompressed = Zlib::GzipReader.new(handle)
  records = DnaIO.new(uncompressed)
  records.to_a
end

def make_subset(args={})
  
  sample_size = args[:sample_size]
  start, stop = args[:start], args[:stop]
  database = args[:database]
  out_folder = args[:out_folder]
  
  puts 'Creating a subset of the data'
  puts "SAMPLE_SIZE = #{sample_size}"
  puts "REGION = #{start}, #{stop}"
  
  # grab a random sample of sequence from DB
  database.shuffle!
  $stderr.puts "loaded #{database.length} records"

  full_out = File.open("#{out_folder}/full.fasta", 'w')
  trun_out = File.open("#{out_folder}/truncated.fasta", 'w')

  samples_remaining = sample_size
  
  while samples_remaining > 0
    record = database.pop
    if record == nil
      fail 'ran out of records in database'
    end
    truncated_sequence = record.sequence[start..stop]
    if truncated_sequence.tr(' -.', '').length == 0
      next
    else
      samples_remaining -= 1   
      full_out.puts record
      record.sequence = truncated_sequence
      trun_out.puts record
    end
  end
  [full_out, trun_out].each { |h| h.close }
end

def convert_alignment(args={})
  i, o = args[:in], args[:out]
  
  ff = Bio::FlatFile.auto(i).to_a
  aln = Bio::Alignment.new(ff)
  File.open(o, 'w') do |o|
    o.write aln.output :phylip
  end
  
end

# Keep this in memory (Why not?!)
database = load_database(DATABASE)

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
      make_subset(
        :sample_size => sample_size,
        :start => start, 
        :stop => stop,
        :out_folder => out_folder,
        :database => database)
      
      puts "converting alignments to phylip"
      # convert full and truncated alignments to Phylip format
      ['full', 'truncated'].each do |f|
        convert_alignment(:in => "#{out_folder}/#{f}.fasta", :out => "#{out_folder}/#{f}.phy")
      end
      
      puts "computing tree"
      # compute the GTRCAT ML tree using RAxML
      ['full', 'truncated'].each do |f|
        `bin/raxml -m GTRCAT -n tree -T #{CORES} -s #{out_folder}/#{f}.phy > #{out_folder}/raxml.log`
        `mv RAxML_bestTree.tree #{out_folder}/#{f}.tree`
        `mv RAxML* #{out_folder}`
        if $?.to_i != 0
          puts "RAXML crashed!!!"
        end
        `rm RAxML*`
      end
      
      puts "computing tree difference"
      # compute and record difference between full and truncated tree
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