import os
import pandas as pd
import argparse

HERE = os.getcwd()
WS = "%s/workspace" % HERE
# run = 1
# while WS is None or os.path.exists(WS):
#     WS = "%s/workspace/run_%02d" % (HERE, run)
#     run += 1
LIB = f"{HERE}/lib"

MAX_THREADS = 16
MAX_MEM_GB = 110
MAX_MEM_MB = MAX_MEM_GB*1000

input_manifest = os.environ['SMK_INPUT']
assert input_manifest != '', "\nno inputs given!, try:\npipeline.sh run [path/to/reads.manifest.csv]\n"
input_manifest = os.path.abspath(input_manifest)
assert os.path.exists(input_manifest), f"\ninput manifest [{input_manifest}] doesn't exist\n"

if not os.path.exists(WS):
    os.makedirs(WS, exist_ok=True)

samples = {}
for i, row in pd.read_csv(input_manifest).iterrows():
    sample_name = row['sample']
    file = os.path.abspath(row['assembly'])
    ext = file.split('.')[-1]

    sample_dir = f"{WS}/{sample_name}/"
    os.makedirs(sample_dir, exist_ok=True)
    link = f"{sample_dir}/input/genome.fna"
    if not os.path.exists(link):
        os.symlink(file, link)

    samples[sample_name] = link

rule all:
    input:
        expand("%s/{sample}/proteins.tsv" % WS, sample=samples),
        expand("%s/{sample}/checkm/report.tsv" % WS, sample=samples),

rule prodigal:
    input:
        "%s/{sample}/input/genome.fna" % WS
    output:
        nt="%s/{sample}/proteins.fna" % WS,
        aa="%s/{sample}/proteins.faa" % WS,
    shell:
        """ \
            singularity run %s/prodigal.sif prodigal \
                -i {input} -a {output.aa} -d {output.nt} \
        """ % LIB

rule diamond:
    input:
        "%s/{sample}/proteins.faa" % WS
    output:
        "%s/{sample}/proteins.tsv" % WS
    threads: MAX_THREADS
    shell:
        """ \
            %s/diamond blastp -p {threads} -d %s/eggnog_proteins.dmnd \
            -q {input} -o {output} \
            --outfmt 6 qseqid salltitles \
        """ % (LIB, LIB)

rule checkm:
    input:
        "%s/{sample}/input/genome.fna" % WS
    output:
        "%s/{sample}/checkm/report.tsv" % WS
    threads: MAX_THREADS
    shell:
        """singularity run %s/checkm.sif checkm lineage_wf \
            %s/{wildcards.sample}/input/ %s/{wildcards.sample}/checkm/ \
            -t {threads} --reduced_tree \
        && singularity run %s/checkm.sif checkm qa \
            %s/{wildcards.sample}/checkm/lineage.ms %s/{wildcards.sample}/checkm/ --tab_table > {output} \
        """ % (LIB, WS, WS, LIB, WS, WS)

rule draw_kegg_tree:
    shell:
        "echo not dones"

# rule spades_pe:
#     input:
#         r1 = "%s/reads/{sample}_1.fastq" % WS,
#         r2 = "%s/reads/{sample}_2.fastq" % WS,
#     output:
#         contigs = "%s/{sample}/contigs/contigs.fasta" % WS
#     resources:
#         mem_mb=110*1000
#     shell:
#         """singularity run %s/spades.sif spades.py \
#             --meta -t {threads} -m {resources.mem_mb} \
#             -1 {input.r1} -2 {input.r2} -o %s/{wildcards.sample}/contigs/ \
#         """ % (LIB, WS)

# # need scatter here
# rule diamond:
#     shell:
#         "%s/diamond {input.bin}" % LIB

# some visualization...
