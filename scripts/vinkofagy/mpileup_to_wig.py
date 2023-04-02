import sys
import re

f = open(sys.argv[1], "r")
w = 50

last_chrom = ""
matches = 0
cov = 0

lines = f.readlines()
for line in lines:
    chrom, pos, letter, coverage, var, _, _ = line.split()
    if chrom != last_chrom:
        print(f"variableStep chrom={chrom} span={w}")
        last_chrom = chrom

    var = re.sub(r'\^.', '', var)
    matches += var.count('.') + var.count(',')
    cov += int(coverage)

    pos = int(pos)
    if pos % w == 0:
        if cov != 0:
            print(pos - w + 1, (cov-matches)/cov)
        matches = 0
        cov = 0

f.close() 