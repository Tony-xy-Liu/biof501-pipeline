import os
import argparse

HERE = os.getcwd()
WS = None
run = 1
while WS is None or os.path.exists(WS):
    WS = "%s/workspace/run_%02d" % (HERE, run)
    run += 1
LIB = f"{HERE}/lib"

input_dir = os.environ['SMK_INPUT_DIR']
assert input_dir != '', "\nno input given!, try:\npipeline.sh run [path/to/input/folder]\n"
input_dir = os.path.abspath(input_dir)
assert os.path.exists(input_dir), f"\ninput folder [{input_dir}] doesn't exist\n"

if not os.path.exists(WS):
    os.makedirs(WS, exist_ok=True)


rule all:
    input:
        "%{sample}_out"

rule test:
    input:
        "sample"
    output:
        ""

# rule all:
#     input:
#         "%s/{wildcard.sample}/contigs/contigs.fasta" % WS

# rule link_inputs_to_ws:
#     input:
#         input_dir
#     output:
#         directory("%s/reads/" % WS)
#     shell:
#         "ln -s {input} {output}"

# def parse_spades_input(reads_dir):
#     print(reads_dir)
#     return reads_dir

# rule spades_s:
#     input:
#         "%s/reads/{sample}.fastq" % WS
#     output:
#         contigs = "%s/{sample}/contigs/contigs.fasta" % WS
#     threads: 16
#     resources:
#         mem_mb=110*1000
#     shell:
#         """singularity run %s/spades.sif spades.py \
#             --meta -t {threads} -m {resources.mem_mb} \
#             -s {input} -o %s/{wildcards.sample}/contigs/ \
#         """ % (LIB, WS)

# rule spades_pe:
#     input:
#         r1 = "%s/reads/{sample}_1.fastq" % WS,
#         r2 = "%s/reads/{sample}_2.fastq" % WS,
#     output:
#         contigs = "%s/{sample}/contigs/contigs.fasta" % WS
#     threads: 8
#     resources:
#         mem_mb=110*1000
#     shell:
#         """singularity run %s/spades.sif spades.py \
#             --meta -t {threads} -m {resources.mem_mb} \
#             -1 {input.r1} -2 {input.r2} -o %s/{wildcards.sample}/contigs/ \
#         """ % (LIB, WS)

# rule maxbin2:
#     shell:
#         "singularity run %s/maxbin2.sif run_MaxBin.pl {input.contigs}" % LIB

# # need scatter here
# rule diamond:
#     shell:
#         "%s/diamond {input.bin}" % LIB

# some visualization...
