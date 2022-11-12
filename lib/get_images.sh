singularity build spades.sif docker://staphb/spades
singularity build maxbin2.sif docker://nanozoo/maxbin2

wget https://github.com/bbuchfink/diamond/releases/download/v2.0.15/diamond-linux64.tar.gz
tar -xzf ./diamond-linux64.tar.gz
rm diamond-linux64.tar.gz
