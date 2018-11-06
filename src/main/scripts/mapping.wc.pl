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


open(BL,$blastRes) or die "#### [ERROR]\t",scalar(localtime()),"\tCan't open the blast results table $blastRes\n";
while (my $blRec=<BL>) {
	chomp $blRec;
	my ($seqMod,$qseqMod)= ();
	my ($qseqid,$sseqid,$pident,$length,$mismatch,$gapopen,$qstart,$qend,$sstart,$send,$evalue,$bitscore,$qseq,$sseq,$qframe,$frames,$btop,$sstrand)= split(/\t/,$blRec);
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
		$qP1Len=0+$qstart;
		}
	my $qP1= substr $qseqMod, 0,$qP1Len;
	my $qMa= substr $qseqMod, $qstart-1,$length;
	my $qP2= substr $qseqMod, $qend,($qSeqLength-$qend);
	my ($sModStart,$sModEnd)=();
	if ($send < $sstart){$sModStart=$send; $sModEnd=$sstart;}
	else {$sModStart=$sstart; $sModEnd=$send;}
	my $sP1Len=();
	if ($sModStart==1){
		$sP1Len=0;
		}
	else {
		$sP1Len=0+$sModStart;
		}
	my $sP1= substr $seqMod, 0, $sP1Len;
	my $sMa= substr $seqMod, $sModStart, $length;
	my $sP2= substr $seqMod, $sModEnd,($sSeqLength-$sModEnd);
	#print "$qseqMod\t[$qstart-$qend]\t$qseqid\n$qP1-$qMa-$qP2\n$qseq\n$seqMod\t[$sstart-$send][$sModStart-$sModEnd]\t$sseqid\n$sP1-$sMa-$sP2\n$sseq\n\n";
	print "$qP1-$qMa-$qP2\t[$qstart-$qend]\t$qseqid\n$sP1-$sMa-$sP2\t[$sModStart-$sModEnd]\t$sseqid\n\n";



	#exit;
	}
