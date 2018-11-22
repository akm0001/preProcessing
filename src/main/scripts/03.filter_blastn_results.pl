use strict;
use warnings;
use Data::Dumper;

my $inp=$ARGV[0];
my $fileID=$ARGV[1];
my $outDir=$ARGV[2];


if ((!$inp) || (!-e $inp)|| (!$fileID) || (!$outDir)) {
	print "#### [ERROR]\t",scalar(localtime()),"\tCheck usage: perl 03.filter_blastn_results.pl /home/anand/Documents/preProcessing/src/main/test/blast.results.SRR7971416.txt SRR7971416 /home/anand/Documents/preProcessing/src/main/test/\n";
	exit;
	}

my (%sraID,%unique,%blastnMap)=();

open (RES,"$inp") or die "\n#### [ERROR]\t",scalar(localtime()),"\tCan't open the blast output file $inp\n";
open (BLAST,">$outDir/$fileID.blast.out.mod.txt") or die "\n#### [ERROR]\t",scalar(localtime()),"\tCan't write to $outDir\n";
print BLAST "qseqid\tqstart\tqend\tlength\tnident\tqlen\tqseq\tsseqid\tsstart\tsend\tslen\tsstrand\tsseq\tpident\tbitscore\tevalue\n";
while (my $res=<RES>){
	chomp $res;
	#my ($qseqid,$sseqid,$pident,$length,$mismatch,$gapopen,$qstart,$qend,$sstart,$send,$evalue,$bitscore)= split (/\t/,$res);
	#my ($qseqid,$sseqid,$pident,$length,$mismatch,$gapopen,$qstart,$qend,$sstart,$send,$evalue,$bitscore,$qseq,$sseq,$qframe,$sframe,$btop,$sstrand) = split(/\t/,$res);
	# qseqid qstart qend length nident qlen qseq sseqid sstart send slen sstrand sseq pident bitscore evalue #preferred blast ouput
	my ($qseqid,$qstart,$qend,$length,$nident,$qlen,$qseq,$sseqid,$sstart,$send,$slen,$sstrand,$sseq,$pident,$bitscore,$evalue) = split(/\t/,$res);
	if ($sstrand eq "minus") {$sstrand= "-";}
	if ($sstrand eq "plus") {$sstrand= "+";}
	print BLAST "$qseqid\t$qstart\t$qend\t$length\t$nident\t$qlen\t$qseq\t$sseqid\t$sstart\t$send\t$slen\t$sstrand\t$sseq\t$pident\t$bitscore\t$evalue\n";
	#my $scientific_notation = "$evalue";
	#my $decimal_notation = sprintf("%.20f", $scientific_notation);
	#my $val="$qseqid|$decimal_notation";
	my $val="$qseqid|$evalue|$pident|$length|$nident|$qlen|$qstart|$qend|$sstart|$send|$bitscore|$qseq|$sseq";
	my $key="$sseqid";
	my $blastnKey="$qseqid|$sseqid|$evalue";
	my $blastnVal="$res";
	$blastnMap{$blastnKey}=$blastnVal;
	if (exists $sraID{$key}) {
		$sraID{$key}= $sraID{$key}.",".$val;
		}
	else {
		$sraID{$key}= $val;
		}
	}
close RES;
#print Dumper (\%sraID);

open (TEMP,">$outDir/$fileID.temp.blast.map.txt") or die "\n#### [ERROR]\t",scalar(localtime()),"\tCan't write to $outDir\n";
open (OUT,">$outDir/$fileID.blast.filtered.txt") or die "\n#### [ERROR]\t",scalar(localtime()),"\tCan't write to $outDir\n";

foreach my $key (sort keys %sraID){
	my @vals= split (/\,/, $sraID{$key});
	my (@tRNA,@evals,@res)= ();
	for (my $i=0;$i<=$#vals;$i++){
		my ($id,$val) =split(/\|/,$vals[$i]);
		push @tRNA,$id;
		push @evals,$val;
		}
	my @list = sort { $a <=> $b } @evals;
	my (@evalIndex)= retIndex($list[0],@vals);
	#print TEMP "$key\t$list[0]\t", join(",", @evalIndex), "\t\t\t$sraID{$key}\n";
	my $tempStrM=join("|", @evalIndex);
	$tempStrM=~ s/\t/\,/g;
	print TEMP "$key\t$list[0]\t$tempStrM\n";
	my %seenArr = ();
	my @uniqValIndex = grep {!$seenArr{$_}++}@evalIndex;

	for (my $j=0;$j<=$#uniqValIndex;$j++){
		print OUT "$key\t$uniqValIndex[$j]\t$list[0]\n";
		}
	}


sub retIndex {
	my ($query,@inpArr)=@_;
	my (@indexes)=();
	for (my $i=0;$i<=$#inpArr;$i++){
		my ($trnaID,$eval,@resStr)=split(/\|/,$inpArr[$i]);
		if ($query == $eval){
			my $tempStr="$trnaID\t".join("\t",@resStr);
			push @indexes, $tempStr;
			}
		}
	return (@indexes);
	}
