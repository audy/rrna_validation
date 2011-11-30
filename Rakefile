require 'zlib'
require 'open-uri'

DATABASE = 'http://www.arb-silva.de/typo3conf/ext/myth_repository/secure.php?u=0&file=fileadmin/silva_databases/release_108/Exports/SSURef_108_tax_silva_full_align_trunc.fasta.tgz&t=1322679885&hash=fb69df7a1c9db2cd7375e9e0caefc61a'

task :default => ['database.gz', 'bin/treedistpair', 'bin/raxml'] do
  
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