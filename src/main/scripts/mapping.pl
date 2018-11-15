#usage: perl preProcessing/src/main/scripts/mapping.pl SRR7971417/SRR7971417/SRR7971417.AT.COL.tab.txt preProcessing/src/main/test/human.hg19.tRna.map.txt temp.bl.txt > map.out.txt
use strict;
#use warnings;
use Data::Dumper;

my $subject= $ARGV[0];
my $querySeq= $ARGV[1];
my $blastRes= $ARGV[2];
my $outDir= $ARGV[3];

my %subHeaderMap=();
open(FA,$subject) or die "#### [ERROR]\t",scalar(localtime()),"\tCan't open the Reference fasta table $subject\n";
while (my $subRec= <FA>) {
	chomp $subRec;
	my ($sHead,$sSeq)= split(/\t/,$subRec);
	$subHeaderMap{$sHead}= $sSeq;
	}
close FA;
#print Dumper(\%subHeaderMap);

my %queryHeaderMap=();
open(QR,$querySeq) or die "#### [ERROR]\t",scalar(localtime()),"\tCan't open the query fa map $querySeq\n";
while (my $qrRec= <QR>) {
	chomp $qrRec;
	my ($qHead,$qSeq,$qInfo)= split(/\t/,$qrRec);
	$qHead=~ s/^\>//;
	if (exists $queryHeaderMap{$qHead}){
		$queryHeaderMap{$qHead}= $queryHeaderMap{$qHead}."|".$qSeq;
		}
	else {
		$queryHeaderMap{$qHead}= $qSeq;
		}
	}
close QR;
#print Dumper(\%queryHeaderMap);

my $resultFile="$outDir/readMapping.temp.txt";
##open(OUT,">$resultFile") or die "#### [ERROR]\t",scalar(localtime()),"\tCan't write to $resultFile\n";

open(BL,$blastRes) or die "#### [ERROR]\t",scalar(localtime()),"\tCan't open the blast results table $blastRes\n";

my %tempMap=();

while (my $blRec=<BL>) {
	chomp $blRec;
	my ($seqMod,$qseqMod)= ();
	#my ($qseqid,$sseqid,$pident,$length,$mismatch,$gapopen,$qstart,$qend,$sstart,$send,$evalue,$bitscore,$qseq,$sseq,$qframe,$frames,$btop,$sstrand)= split(/\t/,$blRec);
	my ($sseqid,$qseqid,$pident,$length,$mismatch,$gapopen,$qstart,$qend,$sstart,$send,$biitscore,$qseq,$sseq)= split(/\t/,$blRec);
	if ($sstart > $send) {
		$seqMod= reverse $subHeaderMap{$sseqid};
		$seqMod=~ tr/ACGTacgt/TGCAtgca/;
		}
	else {
		$seqMod= $subHeaderMap{$sseqid};
		}

	my @qseqArr= split(/\|/,$queryHeaderMap{$qseqid});
	for(my $i=0;$i<=$#qseqArr;$i++) {
		my $loc = index($qseqArr[$i],$qseq);
		if($qseqArr[$i]=~ /$qseq/){
			$qseqMod=$qseqArr[$i];
			}
		if ($loc > 1) {$qseqMod=$qseqArr[$i];}
		}
	#print "$qseqid\n$sseqid\nQry--$queryHeaderMap{$qseqid}\nQmo--$qseqMod\nseq--$qseq\nSub--$subHeaderMap{$sseqid}\nRev--$seqMod\n\n";
	#print "$qseqMod\t[$qstart-$qend]\t$qseqid\n$qseq\n$seqMod\t[$sstart-$send]\t$sseqid\n$sseq\n\n";
	my $qSeqLength=length($qseqMod);
	my $sSeqLength=length($seqMod);
	my $qP1Len=();
	if ($qstart==1){
		$qP1Len=0;
		}
	else {
		$qP1Len=$length;
		}
	my $qP1= substr $qseqMod, 0,$qstart-1;
	my $qMa= substr $qseqMod, $qstart-1,$length;
	my $qP2= substr $qseqMod, $qend,($qSeqLength-$qend);

	my ($sModStart,$sModEnd)=();
	if ($send < $sstart){$sModStart=($sSeqLength-$sstart)+1; $sModEnd=($sSeqLength-$send);}
	else {$sModStart=$sstart; $sModEnd=$send;}
	my $sP1Len=();

	if ($sModStart==1){
		$sP1Len=0;
		}
	else {
		$sP1Len=$length;
		}

	my $sP1= substr $seqMod, 0, $sModStart-1;
	my $sMa= substr $seqMod, $sModStart-1, $length;
	my $sP2= substr $seqMod, $sModEnd,($sSeqLength-$sModEnd);
	#"$qseqMod\t[$qstart-$qend]\t$qseqid\n$qP1-$qMa-$qP2\n$qseq\n$seqMod\t[$sstart-$send][$sModStart-$sModEnd]\t$sseqid\n$sP1-$sMa-$sP2\n$sseq\n\n";
	#print "$qP1*$qMa*$qP2\t[$qstart-$qend]\t$qseqid\n$sP1*$sseq*$sP2\t[$sModStart-$sModEnd]\t$sseqid\n\n";
	my $tempStr="$qseqid|$qstart|$qend\t$qP1*$qMa*$qP2\t$sseqid|$sModStart|$sModEnd\t$sP1*$sseq*$sP2";
	$tempMap{$tempStr}=$tempStr;
	##print OUT "$qseqid|$qstart|$qend\t$qP1*$qMa*$qP2\n$sseqid|$sModStart|$sModEnd\t$sP1*$sseq*$sP2\n\n";
	#if (exists $tempMap{$qseqid}){$tempMap{$qseqid}=$tempMap{$qseqid}."#".$tempStr;}
	#else {$tempMap{$qseqid}=$tempStr;}
	#exit;
	print "$tempStr\n";
	}
close OUT;

#print Dumper(\%tempMap);
