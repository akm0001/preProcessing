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
while (my $blRec=<BL>) {
	chomp $blRec;
	my @blTemp= split (/\t/,$blRec);
	my $qCov= sprintf "%.2f", (100 * ($blTemp[3]/$srrIDs{$blTemp[1]}));
	#my $qCov= 100 * ($blTemp[3]/$srrIDs{$blTemp[0]});
	if (defined $srrIDs{$blTemp[1]}){
		print "$blTemp[1]\t$blTemp[0]\t$blTemp[3]\t$srrIDs{$blTemp[1]}\t$qCov\n";
		}
	}
