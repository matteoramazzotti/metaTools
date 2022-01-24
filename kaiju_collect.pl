#!/usr/bin/perl
if (!$ARGV[0]) {
	print STDERR "Usage: kaju_collect.pl infolder\n\n";
	exit;	
}
@files = (@files,split(/\n/,`ls -1 $ARGV[0]/*.kaiju`));
@ranks = qw/phylum class order family genus species/;
foreach $file (@files) {
	$file =~ s/$ARGV[0]\///;
	$header = $file;
	$header =~ s/\.kaiju//;
	push(@headers,$header);
	foreach $rank (@ranks) {
		$curr = $file;
		$curr =~ s/.kaiju/.$rank/;
		print STDERR "Loading $rank for $file in $curr: ";
		open(IN,"$ARGV[0]/$curr") or die "Cannot find $curr in $ARGV[0]\n";
		$cnt = 0;
		while ($line = <IN>) {
			$cnt++;
			next if ($cnt == 1);
			chomp $line;
			@tmp = split(/\t/,$line);
			#name is formatted as true_name_taxid
			$name = $tmp[4]." ".$tmp[3];
			$name =~ s/ /_/g;
			#hash for names across files
			push @{$names{$rank}}, $name;
			$count{$name."@".$rank."@".$file} = $tmp[2];
			$perc{$name."@".$rank."@".$file} = $tmp[1];
		}
		print STDERR "$cnt entries\n";
		close IN;
	}
}

foreach $rank (@ranks) {
	open(OUT1,">$ARGV[0]/$rank.perc.txt");
	open(OUT2,">$ARGV[0]/$rank.count.txt");
	print OUT1 "Name\t",join "\t",(sort @headers),"\n";       
	print OUT2 "Name\t",join "\t",(sort @headers),"\n";
	%name_list = map {$_ => 1} @{$names{$rank}};
	print STDERR scalar keys %name_list," names in rank $rank from ", scalar @{$names{$rank}}, " names\n";  
	foreach $name (sort keys %name_list) {
		print OUT1 $name;
		print OUT2 $name;
		foreach $file (@files) {
			$cur = $file;
			$cur =~ s/\.kaiju//;
			print OUT1 "\t",$perc{$name."@".$rank."@".$file} if ($perc{$name."@".$rank."@".$file});
			print OUT1 "\t0" if (!$perc{$name."@".$rank."@".$file});
                        print OUT2 "\t",$count{$name."@".$rank."@".$file} if ($count{$name."@".$rank."@".$file});
                        print OUT2 "\t0" if (!$count{$name."@".$rank."@".$file});
		}
		print OUT1 "\n";
		print OUT2 "\n";
	}
	close OUT1;
	close OUT2;
}
