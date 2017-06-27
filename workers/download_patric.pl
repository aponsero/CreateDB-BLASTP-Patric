=pod

=head1 FTP_PATRIC_taxo_KEGG

Download from PATRIC FTP server from an ids list, the ffn and pathway files

=head1 DESCRIPTION

download the Patric's files 

=head1 AUTEUR

A. Ponsero

=head1 VOIR AUSSI

L<Top |/"FTP_PATRIC_taxo_KEGG">

=cut

use 5.010;
use strict;
use warnings;

use LWP::Simple;
use LWP::UserAgent;
use File::Copy;
use Net::FTP;
use XML::LibXML;


 
#get the file containing the ids to download
my $name   = $ARGV[0];


#static declarations
my $filenameimport = $name;
my $ftppostfix1 = '.PATRIC.features.tab';
my $ftppostfix2 = '.PATRIC.ffn';
my $ftppostfix3 = '.PATRIC.faa';
my $ftppostfix4 = '.PATRIC.pathway.tab';

#change dir for download
chdir $name.'.dir';

#connexion FTP

my $ftp = Net::FTP->new("ftp.patricbrc.org", Debug => 0)
or die "Cannot connect to ftp.patricbrc.org: $@";

$ftp->login("anonymous", '-anonymous@')
or die "Cannot login to ftp.patricbrc.org", $ftp->message;

$ftp->cwd("/patric2/genomes/") or die "Cannot change working directory in ftp.patricbrc.org", $ftp->message;

#parse the ids file and get the .cds.tab + .ffn + .faa + .pathway.tab

if (open(my $fh, '<', $filenameimport)){

	while (my $row = <$fh>) {
		chomp $row;

	    #download file from FTP server
		$ftp->get($row.'/'.$row.$ftppostfix1) or warn "FTP : get ($row.PATRIC.features.tab) failed ", $ftp->message;
		$ftp->get($row.'/'.$row.$ftppostfix2) or warn "FTP : get ($row.PATRIC.ffn) failed", $ftp->message;
		$ftp->get($row.'/'.$row.$ftppostfix3) or warn "FTP : get ($row.PATRIC.faa) failed", $ftp->message;
		$ftp->get($row.'/'.$row.$ftppostfix4) or warn "FTP : get ($row.PATRIC.pathways.tab) failed", $ftp->message;
	    
	    #end-download file from FTP server
	 
	  }#end while, look for the following ids
		
	$ftp->quit;
	  
}else{warn "Could not open file '$filenameimport' $!";}

#end of job
1;
