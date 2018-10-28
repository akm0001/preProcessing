use strict;
use warnings;
use Data::Dumper;

my $sra_acc=$ARGV[0];
my $outDir=$ARGV[1];
my $fastq_dump=$ARGV[2];
my $trimmomatic=$ARGV[3];
my $adapters=$ARGV[4];

if ((!$sra_acc)||(!$outDir)||(!$fastq_dump)||(!$trimmomatic)||(!$adapters)){
	print "[ERROR]\t",scalar(localtime()),"\tCheck usage: perl fastq_preprocessing.pl <SRA accession ID> <output directory> <fast-dump path> <trimmomatic path> <adapter_sequence.fa>\t example: perl fastq_preprocessing.pl SRR7971416 /home/anand/Documents/temp/ /home/anand/Downloads/sratoolkit.2.9.2-ubuntu64/bin/fastq-dump /home/anand/Downloads/Trimmomatic-0.38/trimmomatic-0.38.jar /home/anand/Downloads/Trimmomatic-0.38/adapters/TruSeq3-SE.fa\n";
	exit;
	}

my $createWD="mkdir -p $outDir/$sra_acc";
my $exec_fastqDump="$fastq_dump $sra_acc -O $outDir/$sra_acc";
#my $trimmedFastq="$outDir/$sra_acc/$sra_acc.trimmed.fq.gz";
my $trimmedFastq="$outDir/$sra_acc/$sra_acc.trimmed.fastq";
my $exec_trimmomatic="java -jar $trimmomatic SE -phred33 $outDir/$sra_acc/$sra_acc.fastq $trimmedFastq ILLUMINACLIP:$adapters:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:25";

print "[INFO]\t",scalar(localtime()),"\tProcessing $sra_acc\n";
system("$createWD");

print "[INFO]\t",scalar(localtime()),"\t$exec_fastqDump\n";
#system("$exec_fastqDump");

print "[INFO]\t",scalar(localtime()),"\t$exec_trimmomatic\n";
#system("$exec_trimmomatic");

my %readsMap= ();
if (-e $trimmedFastq) {

	open (FQ,"$trimmedFastq") or die "[ERROR]\t",scalar(localtime()),"\tCan't open the $trimmedFastq file\n";
	my $rowSN= 0;
	my ($header,$sequence)= ();

	while (my $rec=<FQ>) {
		chomp $rec;

		if ($rowSN % 4 == 0){
			#print "---$rec\t";
			$header= $rec;
			$rowSN= 0;
			}

		if ($rowSN == 1) {
			#print "---$rec\n";
			$sequence= $rec;
			}

		if (exists $readsMap{$sequence}) {
			$readsMap{$sequence}= $readsMap{$sequence}."|".$sequence;
			}
		else {
			$readsMap{$sequence}= $sequence;
			}

		$rowSN++;

		}
	close FQ;
	}

#print Dumper(\%readsMap);

#my $unID= keys %readsMap;
my $outputFasta= "$outDir/$sra_acc/$sra_acc.deDup.fasta";
open (OUTFILE,">$outputFasta") or die "[ERROR]\t",scalar(localtime()),"\tCan't write to $outputFasta\n";;

foreach my $uniqSeq (keys %readsMap) {
	if ($uniqSeq eq "") { next; }
	my @readHeaders= split (/\|/,$readsMap{$uniqSeq});
	#print "$uniqSeq\t$readsMap{$uniqSeq}\n";
	my $newHeader= ">$sra_acc\_".scalar (@readHeaders);
	print OUTFILE "$newHeader\n$uniqSeq\n";
	}
close OUTFILE;

print "[INFO]\t",scalar(localtime()),"\tOutput generated: $outputFasta\n"
