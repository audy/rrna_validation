require 'zlib'
require 'open-uri'

REGION = ENV['RANGE'].split.collect{ |x| x.to_i }
SAMPLE_SIZE = ENV['SAMPLE_SIZE']
CORES = ENV['CORES']
DATABASE = 'http://www.arb-silva.de/typo3conf/ext/myth_repository/secure.php?u=0&file=fileadmin/silva_databases/release_108/Exports/SSURef_108_tax_silva_full_align_trunc.fasta.tgz&t=1322679885&hash=fb69df7a1c9db2cd7375e9e0caefc61a'

directory 'data' do mkdir 'data' end

desc 'download database'
file 'database.gz' do
  puts "Downloading, filtering and saving database"
  puts "DATABASE = #{DATABASE}"
  
  handle = Zlib::GzipReader.new(open(DATABASE))
  
  records = DnaIO.new(handle)
  output = Zlib::GzipWriter.open('database.gz')
  
  skip = %w[uncultured metagenome]
  need = %w[bacteria]
  kept, total = 0, 0
  records.each do |record|
    keep = false
    need.each { |k| keep = record.name.downcase.include?(k) }
    skip.each { |s| keep = !record.name.downcase.include?(s) }
    if keep
      output.write record "\n"
      kept += 1
    end
    total += 1
  end
  
  puts "kept: #{kept}, skipped: #{total-kept}, total: #{total}"
end

desc 'make subset of data'
file 'data/full.fasta' => 'data/' do
  puts 'Creating a subset of the data'
  puts "SAMPLE_SIZE = #{SAMPLE_SIZE}"
  
  # grab a random sample of sequence from DB
  handle = File.open('test.gz')
  uncompressed = Zlib::GzipReader.new(handle)

  records = DnaIO.new(uncompressed).to_a.shuffle!
  $stderr.puts "loaded #{records.length} records"

  full_out = File.open('data/full.fasta', 'w')
  trun_out = File.open('data/truncated.fasta', 'w')

  samples_remaining = SAMPLE_SIZE
  start, stop = REGION
  while samples_remaining > 0
    record = records.shuffle.pop
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

desc 'convert fasta alignment to phylip alignment'
file 'data/full_alignment.phy' do
  require 'bio'
  ['full', 'truncated'].each do |f|
    ff = Bio::FlatFile.auto("data/#{f}.fasta").to_a
    aln = Bio::Alignment.new(ff)
    File.open("data/#{f}_alignment.phy", 'w') do |o|
      o.write aln.output :phylip
    end
  end
end

desc 'compute tree with RAxML'
task :tree do
  ['full', 'truncated'].each do |f|
    sh "bin/raxml -m GTRCAT -n tree -T #{CORES} -s data/#{f}_alignment.phy"
    sh "mv RAxML_bestTree.tree data/#{f}.tree"
    sh 'rm RAxML*'
  end
end

desc 'compute difference between full and truncated tree'
task :diff => 'data/full.tree' do
  sh 'rm -f outfile'
  sh 'cat data/truncated.tree data/full.tree > intree'
  sh 'bin/treedist < treedistargs > /dev/null'
  data = File.read('outfile')
  score = data.match(/Trees 1 and 2:\s*(.*)/).to_a[1]
  puts "difference is: #{score}"
end