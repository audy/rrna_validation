require 'zlib'
require 'bio'
  
# run alignment
def run_alignment(args={})
  input = args[:in]
  output = args[:out]
  `bin/muscle -in #{input} -out #{output} -quiet`
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
  start, stop = args[:start], args[:stop]
  records = args[:records]
  out_folder = args[:out_folder]
  
  # output full records
  File.open("#{out_folder}/full.fasta", 'w') do |handle|
    records.each do |record|
      handle.puts record
    end
  end
  
  # Output truncated records
  nucleotides = 0
  i = 0
  while (nucleotides/sample_size.to_f < (stop - start))
    i += 1
    records.each do |record|
      n = record.sequence[i]
      # normal and ambiguous nucleotides
      if n =~ /[RYSWKMBDHVNGAUTC]/i
        nucleotides += 1
      elsif n =~ /[-\.]/
        # do nothing about gaps
      else
        fail "weird character: #{n}"
      end
    end
  end
  
  File.open("#{out_folder}/truncated.fasta", 'w') do |handle|
    records.each do |record|
      handle.puts ">#{record.name}\n#{record.sequence[start, start+i]}"
    end
  end
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
