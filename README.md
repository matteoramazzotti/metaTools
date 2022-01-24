# metaTools
A suite of Perl scripts for metagenomics

<b><u>Kaiju section:</b></u>

<table>
<tr><td>kaiju_collect.pl</td><td>Collects kaiju predictions at different ranks (output of kaiju2table), for every available file, creating convenient samplexrank tables<br>Usage: kaju_collect.pl infolder.</td></tr>
  
<tr><td>pycrust2_prep.pl</td><td>Converts the output of kaiju.collect.pl into fasta and biom files needed for running pycrust2.<br>
Usage: picrust2_prep.pl infile outfile RDPdb<br>
 infile: the table produced by kaiju_collect.pl<br>
outfile: an arbitrary output file<br>
  RDPdb: the directory with RDP unaligned db are stored<br>
</td></tr>
</table>
