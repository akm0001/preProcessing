use strict;
use warnings;
use Data::Dumper;

my $inpMap=$ARGV[0];
my %qSeqMap=();
my %qIDs=();

open(MAP,"$inpMap") or die "can't open the mapping file\n";
while(my $rec=<MAP>){
	chomp $rec;
	my ($tempqID,$tempqSeq,$tempsID,$tempsSeq)= split(/\t/,$rec);
	my ($qID,$qStart,$qEnd)= split(/\|/,$tempqID);
	my ($sID,$sStart,$sEnd)= split(/\|/,$tempsID);
	my $tempqSeqMod=$tempqSeq;
	$tempqSeqMod=~ s/\*//g;
	if (exists $qSeqMap{$tempqSeqMod}) {
		$qSeqMap{$tempqSeqMod}=$qSeqMap{$tempqSeqMod}."#".$qID;
		}
	else {
		$qSeqMap{$tempqSeqMod}=$qID;
		}

	#$qIDs{$qID}="$tempsSeq|$qStart|$qEnd\t$";
	my $str="$qStart|$qEnd|$tempqSeq|$sID|$sStart|$sEnd|$tempsSeq";	
	if (exists $qIDs{$qID}) {
		$qIDs{$qID}=$qIDs{$qID}."#".$str;
		}
	else {
		$qIDs{$qID}=$str;
		}
	}
close MAP;

#print Dumper(\%qSeqMap);

#%qSeqMap=CCTTCGATAGCTCAGTTGGTAGAGCGGAGGACTGTAGTGGATAGGGCGTGGCAATCCTTAGGTCGCTGGTTCGATTCCGGCTCGAAGGA==Hs_tRNA.Y.GTA.2#Hs_tRNA.Y.GTA.2
#%qID= Hs_tRNA.C.GCA.10==8|35|GGGGGTA*TAGCTCAGGGGTAGAGCATTTGACTGCA*GATCAAGAGGTCCCTGGTTCAAATCCAGGTGCCCCCC|SRR7971417_0151461_10_0.44|4|30|ATG*TAGCTCAGGGGTAGAGCATTTGACTGCA*AAATGCATTGGATATGAACC#

foreach my $key(sort keys %qSeqMap){
	my %seenArr= ();
	my @listIDs= split(/\#/,$qSeqMap{$key});
	my @uniqIds= grep {!$seenArr{$_}++}@listIDs;
	my $lenQSeq=length($key);
	my @mappedReads=split(/\#/,$qIDs{$uniqIds[0]});
	my $lenRefScale=30+$lenQSeq+30;
	for(my $i=0;$i<=$lenRefScale;$i++){
		if (($i>=30) && ($i<=(30+$lenQSeq))){
	#		print $key;
			}
	#	else {print "_";}
		}
	#print "\n";
	my @refSeqStr=split(//,$key);
	for(my $i=-30;$i>=8;$i++){
		print "$i";
		#print $i;
		}
	print "\n";
	#print "$refSeqStr[8]#$refSeqStr[7]";
	print join("|",@refSeqStr),"\n";
	#print "$uniqIds[0]\t$key\n$qIDs{$uniqIds[0]}\n";
	}
