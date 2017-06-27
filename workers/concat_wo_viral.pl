use 5.010;
use strict;
use warnings;

use LWP::Simple;
use LWP::UserAgent;
use File::Copy;
use Net::FTP;
use XML::LibXML;
use Bio::SeqIO;

my $report = $ARGV[0];
my $output= $ARGV[1];
my $log= $ARGV[2];

my %map_fig_product;

if (open(my $fh, '<', $report)) {

if (open(my $flog, '>', $log)) {

	while (my $id = <$fh>) {
		chomp $id;

		my $cds = "$id.PATRIC.faa";
		my $features = "$id.PATRIC.features.tab";

		
		if(-e $cds){
		if(-e $features){

		open (PATH, $features);
		#load features in hashmap
		my %map_locus_fig;

		while (my $line2 = <PATH>) {
      			chomp $line2;
      			my @myfields= split(/\t/, $line2);
			my $patric_id=$myfields[5];
			my $figFam=$myfields[15]||"undef";
			my $product=$myfields[14];
			if(($figFam =~ "FIG") and ($patric_id =~ "fig")){

				print "in map : $patric_id --> $figFam\n"; 
				$map_locus_fig{$patric_id}=$figFam;
				$map_fig_product{$figFam}=$product;
			}

		}	
		print "working on $cds\n";

		my $in  = Bio::SeqIO-> new ( -file   => $cds,
						-format => 'fasta' );
		my $out = Bio::SeqIO-> new ( -file   => ">> $output",
                				-format => 'fasta' );

		while (my $record = $in->next_seq()) {
			
			my $product = $record->desc();
			my $seq_id = $record->id();
			my $seq = $record->seq();
			if (!($product =~ /hypothetical protein|phage|integration host factor|retron|possible|predicted|probable|putative|recombination|mobile element/i)) {
				
				my @fields = split(/\|/, $seq_id);

				my $new_id=$fields[0]."|".$fields[1];

			###GARDER sequence uniquement si FIGFam associée !!	
				if (defined $map_locus_fig{$new_id}){
					print "found $new_id -- $map_locus_fig{$new_id}\n";

					my $figID=$map_locus_fig{$new_id};
					my @temp=split(/\|/, $new_id);
					
					$new_id="lcl|BLAST-".$temp[0]."-".$temp[1]."_".$figID;
					$record->display_id($new_id);
					$record->desc("");
					$out->write_seq($record);
				}}		
			}
		}else{warn "could not find $cds";}
		}else{warn "could not find $features";}
		}


foreach my $key ( keys %map_fig_product ){
	print $flog "$key	$map_fig_product{$key}\n";
}

} else {warn "Could not open $log";}
} else {warn "Could not open $report";}

#end of job  
