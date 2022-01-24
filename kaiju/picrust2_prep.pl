#!/usr/bin/perl
#(c) matteo.ramazzotti@unifi.it
if (!$ARGV[0]) {
	print STDERR "picrust2_prep.pl infile outfile RDPdb\n\n";
	print STDERR " infile: the table produced by kaiju_collect.pl\n";
	print STDERR "outfile: an arbitrary output file\n";
	print STDERR "  RDPdb: the directory with RDP unaligned db are stored\n\n";
	exit;
}

$in = shift @ARGV;
$out= shift @ARGV;
$db = shift @ARGV;
$db = "." if (!$db);

if (!-e "$db/current_Bacteria_unaligned.fa.gz") {
	`wget https://rdp.cme.msu.edu/download/current_Bacteria_unaligned.fa.gz`; 
	`wget https://rdp.cme.msu.edu/download/current_Archaea_unaligned.fa.gz`;
}

open(OUT1,">$out.table");
open(OUT2,">$out.fasta");
open(OUT3,">$out.tax");
print OUT3 "#OTUID\ttaxonomy\tconfidence\n";
open(IN,"$ARGV[0]");
$cnt = 0;
while($line= <IN>) {
	$cnt++;
	print OUT1 $line if ($cnt == 1);
	next if ($cnt == 1);
	chomp $line;
	$abu = $line;
	$abu =~ s/.+?\t//; #all but names
	$name = $line;
	$name =~ s/_\d+.*//; #only names
	$name =~ s/_/ /;
	$name =~ s/[\[\]]//g;
	$otu{$name} = $abu;
}
#close OUT;
close IN;
$ind = 0;
print scalar keys %otu, " species loaded.\n";
open(IN,"zcat $db/current_Bacteria_unaligned.fa.gz $db/current_Archaea_unaligned.fa.gz | FASoneline.pl |");
while($line= <IN>) {
	chomp $line;
	if ($line =~ />/) {
		$ind++;
		$line =~ />S\d+ (.+?);/;
		$name = $1;
		$name =~ s/\tLineage=Root//;
		$line =~ /(Lineage=.+?genus)/;
		$lin = $1;
		$lin =~ s/\"//g;
		@t = split(/;/,$lin);
		$tax = "k__Bacteria; p__$t[4]; c__$t[6]; o__$t[10]; f__$t[14]; g__$t[16]; s__$name;\t-1" if ($lin =~ /Bacteria;domain/);
		$tax = "k__Archaea; p__$t[4]; c__$t[6]; o__$t[10]; f__$t[14]; g__$t[16]; s__$name;\t-1" if ($lin =~ /Archaea;domain/);
	} else {
		if ($otu{$name} && !$used{$name}) {
			print OUT1 "OTU$ind","\t",$otu{$name},"\n";
			print OUT2 ">","OTU$ind","\n",uc($line),"\n";
			print OUT3 "OTU$ind","\t",$tax,"\n";
			$used{$name} = 1;
		}
	}
}
if(!`which biom`) {
	print "biom-format-tools is installed: install? [y/n]";
	$ans = <STDIN>;
	chomp $ans;
	if ($ans eq 'y') {
	`sudo apt install biom-format-tools`;
	} else {
	exit;
	}
} else {
`biom convert -i $outfile.table -o $outfile.table.biom --table-type="OTU table" --to-json`;
`biom add-metadata -i $outfile.table.biom -o $outfile.table.tax.biom --observation-metadata-fp $outfile.tax`;
}
if(`which picrust2_pipeline.py`) {
	`picrust2_pipeline.py -s $outfile.fasta -i $outfile.table.biom -o picrust2_out -p 20`;
}
