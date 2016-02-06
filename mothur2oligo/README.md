This is a shell script for transforming mothur output to appropriate format for A. murat Eren's oligotyping pipeline. To successfully run this script, follow the instructions below.

## Files:
You will need access to the following mothur files to run this script. The examples of file names pertain to the Mothur Miseq [SOP](http://www.mothur.org/wiki/MiSeq_SOP)    
	- **taxonomy file:** stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.pds.wang.taxonomy        
	- **group file:** stability.contigs.good.groups           
	- **names file:** stability.trim.contigs.good.names     
	- **fasta file:** stability.trim.contigs.good.unique.good.filter.fasta     
   
## Steps:

1) Copy all the mothur files listed above into the same directory as this one                 
2) Edit mothur2oligo.sh and fill in the appropriate file names and taxon info at the top.          
3) Once you have run this full script, you can use the '*_headers-replaced.fasta' file in the oligotyping pipeline    
   
Note: Mothur must be in your path

Instructions for downloading the oligotyping software are [here](http://merenlab.org/2014/08/16/installing-the-oligotyping-pipeline/)            
                
Instruction for running the oligotyping software are [here](http://merenlab.org/2012/05/11/oligotyping-pipeline-explained/)   
      
Any questions? contact michberr8@gmail.com

## Credits:    
perl script from http://www.perlmonks.org/?node_id=975419       
Sharon Grim helped with this shell script         
Oligotyping pipeline: http://merenlab.org/projects/oligotyping/         
