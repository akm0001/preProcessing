use strict;
use warnings;

my $sra= $ARGV[0];
my $library= $ARGV[1];
my $scriptDir= "/home/anand/Documents/preProcessing/src/main/scripts/";
my $resultDir= "/home/anand/Documents/SRA_DUMP/";
my $adapter= ();

if ($library eq "SE"){
	$adapter= "/home/anand/Downloads/Trimmomatic-0.38/adapters/TruSeq3-SE.fa";
	}
elsif ($library eq "PE"){
	$adapter= "/home/anand/Downloads/Trimmomatic-0.38/adapters/TruSeq3-PE-2.fa";
	}
else {
	print "#### [ERROR]\t",scalar(localtime()),"\tInvalid input for Library type. Use 'SE' for 'Single End' and 'PE' for 'Paired End'\n\n";
	exit;
	}

my $step1Comm= "perl $scriptDir/02.fastq_preprocessing.pl $sra $resultDir /home/anand/Downloads/sratoolkit.2.9.2-ubuntu64/bin/fastq-dump /home/anand/Downloads/Trimmomatic-0.38/trimmomatic-0.38.jar $adapter";
my $step2Comm= "makeblastdb -in $resultDir/$sra/$sra.AT.COL.fa -dbtype 'nucl' -hash_index -out $resultDir/$sra/$sra";
my $step3Comm= "blastn -db $resultDir/$sra/$sra -query /home/anand/Documents/resources/human.hg19.tRna.deDup.fa -out $resultDir/$sra/$sra.blast.results.txt -outfmt \"6 qseqid qstart qend length nident qlen qseq sseqid sstart send slen sstrand sseq pident bitscore evalue\"";
my $step4Comm= "perl $scriptDir/03.filter_blastn_results.pl $resultDir/$sra/$sra.blast.results.txt $sra $resultDir/$sra/";
my $step5Comm= "perl $scriptDir/04.mapping.pl $resultDir/$sra/$sra.AT.COL.tab.txt /home/anand/Documents/resources/human.hg19.tRna.map.txt $resultDir/$sra/$sra.blast.filtered.txt > $resultDir/$sra/$sra.blast.vis.temp.txt";
my $step6Comm= "perl $scriptDir/05.visMap.pl $resultDir/$sra/$sra.blast.vis.temp.txt > $resultDir/$sra/$sra.blast.vis.out.txt";

#print "$step1Comm\n$step2Comm\n$step3Comm\n$step4Comm\n$step5Comm\n$step6Comm";

print "$step1Comm\n";
system("$step1Comm");

print "$step2Comm\n";
system("$step2Comm");

print "$step3Comm\n";
system("$step3Comm");

print "$step4Comm\n";
system("$step4Comm");

print "$step5Comm\n";
system("$step5Comm");

print "$step6Comm\n";
system("$step6Comm");



