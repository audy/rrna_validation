require 'zlib'
require 'bio'
  
# run alignment
def run_alignment(args={})
  input = args[:in]
  output = args[:out]
  `bin/muscle -in #{input} -out #{output}`
end

# load compressed fasta file into an array of records
def load_database(filename)
  
  handle = File.open(filename)
  uncompressed = Zlib::GzipReader.new(handle)
  records = DnaIO.new(uncompressed)
  records.to_a
end

# grab a subset of the data and save it to a specified file
def make_subset(args={})  
  tries = args[:tries] || 5
  sample_size = args[:sample_size]
  start, stop = args[:start], args[:stop]
  database = args[:database]
  out_folder = args[:out_folder]
  
  puts 'Creating a subset of the data'
  puts "SAMPLE_SIZE = #{sample_size}"
  puts "REGION = #{start}, #{stop}"

  full_out = File.open("#{out_folder}/full.fasta", 'w')
  trun_out = File.open("#{out_folder}/truncated.fasta", 'w')

  samples_remaining = sample_size
  
  while samples_remaining > 0
    record = database.shuffle.first
    
    if record == nil
      puts '!! ran out of records in database'
      if tries > 0
        puts '!! gonna retry'
      else
        puts '!! ran out of tries'
        fail
      end
      full_out = File.open("#{out_folder}/full.fasta", 'w')
      trun_out = File.open("#{out_folder}/truncated.fasta", 'w')
      samples_remaining = sample_size
      tries -= 1
      next
    end
    
    truncated_sequence = record.sequence[start..stop]

    if truncated_sequence == nil
      fail "sequence is too short?"
    elsif truncated_sequence.tr(' -.', '').length == 0
      next
    else
      samples_remaining -= 1   
      full_out.puts record
      truncated_sequence
      trun_out.puts ">#{record.name}\n#{truncated_sequence}"
    end
  end
  [full_out, trun_out].each { |h| h.close }
end

# convert fasta alignment to phylip format
def convert_alignment(args={})
  i, o = args[:in], args[:out]
  
  ff = Bio::FlatFile.auto(i).to_a
  aln = Bio::Alignment.new(ff)
  File.open(o, 'w') do |o|
    o.write aln.output :phylip
  end
  
end
