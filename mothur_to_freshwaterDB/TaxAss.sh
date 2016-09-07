#!/bin/bash
# USAGE: bash -x TaxAss.sh
# This is a shell script for applying the TaxAss pipeline by: https://github.com/McMahonLab/TaxAss

## Set variables
# Adjust the file names to your own study

## fasta of samples to classify
fasta="total.trim.contigs.good.unique.good.filter.unique.precluster.pick.fasta"
## Specific database (FWDB)
fasta_ref="/scratch/vdenef_fluxm/rprops/databases/FreshTrain18Aug2016.fasta"
taxonomy_ref="/scratch/vdenef_fluxm/rprops/databases/FreshTrain18Aug2016.taxonomy"
## General database (SILVA)
general_fasta="/scratch/vdenef_fluxm/rprops/databases/silva.nr_v123.align"
general_tax="/scratch/vdenef_fluxm/rprops/databases/silva.nr_v123.tax"
## Processors, identity threshold for BLAST and location of all the R/python scripts
processors=40
pid=97
script_location="/scratch/vdenef_fluxm/rprops/scripts"

# Remove '-' due to alignment (BLAST can't cope with this)
sed 's/-//g' <$(echo $fasta) >sequence.fasta

# Step 0: Create blast database
makeblastdb -dbtype nucl -in $(echo $fasta_ref) -input_type fasta -parse_seqids -out FWonly_18Aug2016custom.db

# Step 1: Run blast and reformat output blast file
blastn -query sequence.fasta -task megablast -db FWonly_18Aug2016custom.db -out custom.blast -outfmt 11 -max_target_seqs 5 -num_threads $processors
blast_formatter -archive custom.blast -outfmt "6 qseqid pident length qlen qstart qend" -out otus.custom.blast.table

# Step 2: Correct BLAST pident using custom script
### This accounts for sequence length differences
Rscript $(echo "$script_location/calc_full_length_pident.R") otus.custom.blast.table otus.custom.blast.table.modified

# Step 3: Filter BLAST results
Rscript $(echo "$script_location/filter_seqIDs_by_pident.R") otus.custom.blast.table.modified ids.above.97 $pid TRUE
Rscript $(echo "$script_location/filter_seqIDs_by_pident.R") otus.custom.blast.table.modified ids.below.97 $pid FALSE

# Step 4: 
mkdir plots
Rscript $(echo "$script_location/plot_blast_hit_stats.R") otus.custom.blast.table.modified $pid plots

# Step 5: recover sequence IDs left out of blast (python, bash)
python $(echo "$script_location/find_seqIDs_blast_removed.py") sequence.fasta otus.custom.blast.table.modified ids.missing
cat ids.below.97 ids.missing > ids.below.97.all

# Step 6: create fasta files of desired sequence IDs (python)
python $(echo "$script_location/create_fastas_given_seqIDs.py") ids.above.97 sequence.fasta otus.above.97.fasta
python $(echo "$script_location/create_fastas_given_seqIDs.py") ids.below.97.all sequence.fasta otus.below.97.fasta

# Step 7: Screen for minimum length and max number of amibguous bases
# Assign taxonomy to each fasta file
### Classify
mothur "#classify.seqs(fasta=otus.below.97.fasta, template=$general_fasta, taxonomy=$general_tax, method=wang, probs=T, processors=$processors, cutoff=0)"
mothur "#classify.seqs(fasta=otus.above.97.fasta, template=$fasta_ref,  taxonomy=$taxonomy_ref, method=wang, probs=T, processors=$processors, cutoff=80)"

# Step 8: combine taxonomy files and names files
cat otus.above.97.FreshTrain18Aug2016.wang.taxonomy otus.below.97.nr_v123.wang.taxonomy > final.FWDB.Silva.taxonomy
