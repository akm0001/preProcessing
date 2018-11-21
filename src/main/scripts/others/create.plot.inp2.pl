#usage: perl create.plot.inp2.pl /home/anand/Documents/resources/SRR7971417/SRR7971417.AT.COL.tab.txt /home/anand/Documents/resources/SRR7971417.blast.filtered.txt > /home/anand/Documents/resources/test.plot.inp.2.txt
use strict;
use warnings;
use Data::Dumper;

my $srrMap=$ARGV[0];
my $blast=$ARGV[1];

my %srrIDs=();
open (SRR,"$srrMap") or die "can't open the SRR fasta map table\n";
while (my $srrRec=<SRR>) {
	chomp $srrRec;
	my ($srrID,$srrSeq)= split (/\t/,$srrRec);
	my $lengthSeq= length ($srrSeq);
	$srrIDs{$srrID}= $lengthSeq;
	}
close SRR;

#print Dumper(\%srrIDs);

open (BL,"$blast") or die "can't open the blast table\n";
print "SRR_ID\ttRNA_ID\tIdentity\tQ_Cov\n";
while (my $blRec=<BL>) {
	chomp $blRec;
	my @blTemp= split (/\t/,$blRec);
	my $qCov= sprintf "%.2f", (100 * ($blTemp[3]/$srrIDs{$blTemp[0]}));
	#my $qCov= 100 * ($blTemp[3]/$srrIDs{$blTemp[0]});
	if (defined $srrIDs{$blTemp[0]}){
		#print "$blTemp[0]\t$blTemp[1]\t$blTemp[3]\t$srrIDs{$blTemp[0]}\t$qCov\n";
		print "$blTemp[0]\t$blTemp[1]\t$blTemp[2]\t$qCov\n";
		}
	}
