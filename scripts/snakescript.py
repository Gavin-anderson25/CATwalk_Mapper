import CATwalk as ct
import seeder as sd
from Bio import SeqIO

with open("data/catwalkoutput.fasta", "w", encoding="utf-8") as file:
    file.write(f">Extended_CATwalk_Product\n")
    rand_read = sd.randomseq(f"data/reference.fasta", 250)
    catwalk_output = ct.CATwalk(rand_read, f"data/reads.fasta", 2000, 15, 0.001, 1.05)
    file.write(catwalk_output)
