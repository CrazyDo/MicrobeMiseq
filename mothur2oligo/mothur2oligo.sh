#!/bin/sh
# USAGE: ./mothur2oligo.sh
# This is a shell script for transforming mothur output to appropriate format for 
# A. murat Eren's oligotyping pipeline 

# Set variables
# Adjust the groups file name to your own study - this is the filet from the mothur SOP
groups="stability.contigs.good.groups"
redundant="*.pick.redundant.fasta"

# Call mothur script for generating deuniqued fasta file for a specific lineage
mothur getlineage.mothur

# Replace all "_" in fasta header with a ":"
cat $groups | sed 's/_/:/g' > intermediate1
# Make a file which maps sample names to sequence headers
paste $groups intermediate1 | awk 'BEGIN{FS="\t"}{print $1"\t"$2"_"$3}' > intermediate2

# Perl script to rename the headers of the fasta to include the sample name at the beginning followed by a "_"
perl renamer.pl $redundant intermediate2

