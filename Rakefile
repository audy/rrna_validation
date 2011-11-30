require 'zlib'
require 'open-uri'

DATABASE = 'http://www.arb-silva.de/typo3conf/ext/myth_repository/secure.php?u=0&file=fileadmin/silva_databases/release_108/Exports/SSURef_108_tax_silva.fasta.tgz&t=1322768569&hash=71cea202d8c9e82d5cb1fb82811f2e6a'

task :default => ['database.gz', 'bin/treedist', 'bin/muscle', 'bin/raxml', 'database.gz'] do
  
end

file 'bin/muscle' do
  url = "http://www.drive5.com/muscle/downloads3.8.31/muscle3.8.31_i86darwin64.tar.gz"
  sh "curl #{url} > muscle.tar.gz"
  sh 'tar -zxvf muscle.tar.gz'
  sh 'mv muscle3.8.31_i86darwin64 bin/muscle'
  sh 'rm muscle.tar.gz'
end

file 'bin/raxml' do
  sh 'git clone https://github.com/stamatak/standard-RAxML.git'
  sh 'cd standard-RAxML; make --file=Makefile.SSE3.PTHREADS.gcc'
  sh 'mv standard-RAxML/raxmlHPC-PTHREADS-SSE3 bin/raxml'
  sh 'rm -rf standard-RAxML'
end

file 'database.gz' do
  sh "curl -L \"#{DATABASE}\" | tar -zxvOf - SSURef_108_tax_silva.fasta | gzip > database.gz"
end

file 'bin/treedist' do
  sh "hdid http://t.co/v89MflJd"
  puts "Please manually put treedist in bin. THANK YOU VERY MUCH!!!!"
end
