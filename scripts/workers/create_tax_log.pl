=pod

=head1 FTP_PATRIC_taxo_KEGG

Download the taxonomic information from NCBI database and creates the class folder, and copy the ffn/pathways file in them

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

 
my $genome_log= $ARGV[0];
my $taxo_log= $ARGV[1];
my $tax_dir=$ARGV[2];

#static declarations
my $ftppostfix3 = '.PATRIC.faa';
my $ftppostfix4 = '.PATRIC.pathway.tab';
my $eFetchprefix = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=taxonomy&id=";
my $eFetchpostfix = "&retmode=xml";


if (open(my $fh, '<', $genome_log)) {
if (open(my $fout, '>', $taxo_log)) {	
	while (my $genome = <$fh>) {
	    chomp $genome;
	print " found : $genome in $genome_log\n";   
	my @fields = split(/\//, $genome);
	my $genomeID=$fields[-1];
	print "genome ID : $genomeID\n";
	my @sub_genomeID=split(/\./, $genomeID);
	my $taxID = $sub_genomeID[0];
	print "taxo ID : $taxID\n";
	my $url= $eFetchprefix.$taxID.$eFetchpostfix;
	print "url : $url\n";
	my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 });
	my $req = HTTP::Request->new("GET", $url);
	my $rep = $ua->request($req);
	
	if (! defined $rep){
		warn "can't get $url";
	}else {	
		my $filenameexport = $tax_dir."/".$genomeID.'taxo.xml';
           	print "create file : $filenameexport\n";
 
        	if (open(my $fhe, '>', $filenameexport)) {
        		print $fhe $rep->content;
        		close $fhe;
		} else {
			warn "Could not open file '$filenameexport' $!";
		}

		my $dom = XML::LibXML->load_xml(location => $filenameexport);
		my $taxClass='unclassified';
		my $taxPhylum="none";
		my $taxKingdom="none";
 
		foreach my $taxgroupP ($dom->findnodes('/TaxaSet/Taxon/LineageEx/Taxon[Rank="phylum"]/ScientificName')) {
			$taxPhylum = $taxgroupP->to_literal();
          	}

		foreach my $taxgroupK ($dom->findnodes('/TaxaSet/Taxon/LineageEx/Taxon[Rank="superkingdom"]/ScientificName')) {
                        $taxKingdom = $taxgroupK->to_literal();
                }

          
          	if($taxPhylum eq "Cyanobacteria"){
             		$taxClass = "Cyanobacteria";
          	}else{
			
			foreach my $taxgroup ($dom->findnodes('/TaxaSet/Taxon/LineageEx/Taxon[Rank="class"]/ScientificName')) {
              				$taxClass = $taxgroup->to_literal();
				}
		}
		print "in $taxo_log :: $genomeID  $taxKingdom     $taxPhylum      $taxClass\n";
		print $fout "$genomeID	$taxKingdom	$taxPhylum	$taxClass\n";	
	}


	}	

} else {
  warn "Could not open file '$taxo_log' $!";
}

} else {
  warn "Could not open file '$genome_log' $!";
}

#end of job
1;
