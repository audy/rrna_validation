require 'zlib'
require 'open-uri'

DATABASE = 'http://www.arb-silva.de/typo3conf/ext/myth_repository/secure.php?u=0&file=fileadmin/silva_databases/release_108/Exports/SSURef_108_tax_silva_full_align_trunc.fasta.tgz&t=1322679885&hash=fb69df7a1c9db2cd7375e9e0caefc61a'

task :default => ['database.gz', 'bin/treedistpair', 'bin/raxml'] do
  
end

file 'bin/muscle' do
  url = "http://www.drive5.com/muscle/downloads3.8.31/muscle3.8.31_src.tar.gz"
  sh 'curl url > muscle.tar.gz'
end