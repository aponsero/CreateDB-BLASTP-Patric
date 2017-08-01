# CreateDB-BLASTP-Patric
Create a BLASTP bacterial database from a list a genomes from the Patric database. These scripts are meant to be run on an HPC cluster.

Create also a FigFam log containing the list of FigFam annotation found in the genomes and the corresponding protein product.
The last step of this pipeline aims to download the taxonomic informations for each genome and construct a taxonomic log featuring the genome number associated with the taxonomic informations.

## Quick start

### Edit the config.sh file
please modify the 
  - GENOME_LIST = indicate here the log file containing patric ids to download
  - SPLIT_DIR = indicate here the directory to download the genomes files
  - DB_DIR = indicate here the directory containing the final database files
  - MAIL_USER = indicate here your arizona.edu email
  - GROUP = indicate here your group affiliation

You can also modify
  - CD_HIT = change for another CD_HIT/BIN directory
  - BIN = change for your own bin directory.
  
  - CD_SIM = change if you want to modify the similarity parameter of CD-HIT. By default, set to 0.9.
  - MAIL_TYPE = change the mail type option. By default set to "bea".
  
### Run ./submit
this command will submit three jobs in queue. 

### Notes
the download and dereplication steps can take a long time if the genome list is extremely long. If so, modify accordingly the #PBS walltime in scripts/run_get_patric_array.sh and scripts/run_create_DB.sh

Some genomes are not available in PATRIC. Please note that the log out/01-download-genomes contains warning if some genomes are not found in the database.
