## 16S rRNA HtS Trees

Austin G. Davis-Richardson

This was an experiment I did for ZOO6927 - Methods of Phylogenetic Inference. I attempted to benchmark the ability of different regions along the 16S rRNA gene in bacteria for making accurate phylogenetic trees. This was accomplished by creating trees for random sets of taxa with full-length and truncated alignments.

## Installation

Works on Ruby 1.9 on Mac OS X. If you want to run on Linux, you will have to supply your own binaries for treedist, and MUSCLE. If you want to run on Windows you will have to delete windows and install Linux. RAxML is compiled from source.

Install like this:

    $ sudo gem install bundle
    $ bundle
    $ rake
    
At this point you should have all necessary binaries and the greengenes database. You can run the experiment by typing:

    $ bin/run_experiment.rb greengenes_core.fasta.gz
    
To alter the parameters of the experiment, you will need to edit `bin/run_experiment.rb` yourself.

Good luck and have fun!