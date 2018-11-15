#usage: perl visMap.pl mapped.txt
use strict;
use warnings;
use Data::Dumper;

my $map= $ARGV[0];

my %qIDsMap= (); #all the corresponding reads and its IDs
my %qIDSeq= ();

open (MAP,"$map");
while (my $rec= <MAP>){
	chomp $rec;
	my ($qseqInfo,$qseq,$sseqInfo,$sseq)= split(/\t/,$rec);
	my ($qID,$qstart,$qend)= split(/\|/,$qseqInfo);
	my ($sID,$sstart,$send)= split(/\|/,$sseqInfo);
	my $valIDMap="$qstart|$qend|$sID|$sstart|$send|$sseq";
	if (exists $qIDsMap{$qID}) {
		$qIDsMap{$qID}=$qIDsMap{$qID}."#".$valIDMap;
		}
	else {
		$qIDsMap{$qID}=$valIDMap;
		}
	$qseq=~ s/\*//g;
	$qIDSeq{$qID}=$qseq;
	}
close MAP;

#print Dumper(\%qIDsMap);

foreach my $tRnaID (sort keys %qIDsMap) {
	#printf ("%-32s", $tRnaID);
	#print "$qIDSeq{$tRnaID}\n";
	my $lenRna= length($qIDSeq{$tRnaID});
	my $totalRefLen=($lenRna+60);
	my $padding=('-' x 30);
	my $indent=(' ' x 5);
	print $padding.$qIDSeq{$tRnaID}.$padding.$indent.$tRnaID."\n";
	my @mappedList= split(/\#/,$qIDsMap{$tRnaID});
	for (my $i=0;$i<=$#mappedList;$i++){
		my ($posQStart,$posQEnd,$subID,$posSStart,$posSEnd,$sSequence)=split(/\|/,$mappedList[$i]);
		#print "$subID\t$sSequence\t[$posQStart,$posQEnd]\t[$posSStart,$posSEnd]\n";
		#print "$subID\t";
		$sSequence=~ s/\*//g;
		my $readStartPos=(30+$posQStart)-$posSStart;
		my $readPaddingLeft= '-' x $readStartPos;
		my $covLenRead= length ($readPaddingLeft.$sSequence);
		#print $readPaddingLeft.$sSequence. $covLenRead;
		my $readPaddingRightPos=($totalRefLen-$covLenRead);
		my $readPaddingRight= '-' x $readPaddingRightPos;
		print $readPaddingLeft.$sSequence.$readPaddingRight.$indent;
		print "$subID\tRef:[$posQStart,$posQEnd] Read:[$posSStart,$posSEnd]\n";
		}
	print "\n";
	}

