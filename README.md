# CreateDB-BLASTP-Patric
Create a BLASTP bacterial database from a list a genomes from the Patric database

Create also a FigFam log containing the list of FigFam annotation found in the genome and the corresponding protein product
The last step of this pipeline aims to download the taxonomic informations for each genome and construct a taxonomic log featuring the genome number associated with the taxonomic informations.

## Quick start

### Edit the config.sh file
please modify the 
  - GENOME_LIST = indicate here the log file containing patric ids to download
  - SPLIT_DIR = indicate here the directory to download the genomes files
  - DB_DIR = indicate here the directory containing the final database files
  
### Run 01-download-patric.sh
this step can take a long time if the genome list is long. If so, modify accordingly the #PBS walltime
Some genomes are not available in PATRIC, Please check the output log to verify if some genomes are missing

### Run 02-create-DB.sh
This step can take a long time (CD-Hit dereplication step can take few hours). Modify the #PBS walltime accordingly.

### OPTIONAL : Run 03-taxo-log.sh
This step will create a log summarizing taxonomic information from the genomes downloaded.

