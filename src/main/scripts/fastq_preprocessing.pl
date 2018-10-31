use strict;
use warnings;
use Data::Dumper;

my $sra_acc=$ARGV[0];
my $outDir=$ARGV[1];
my $fastq_dump=$ARGV[2];
my $trimmomatic=$ARGV[3];
my $adapters=$ARGV[4];

if ((!$sra_acc)||(!$outDir)||(!$fastq_dump)||(!$trimmomatic)||(!$adapters)){
	print "#### [ERROR]\t",scalar(localtime()),"\tCheck usage: perl fastq_preprocessing.pl <SRA accession ID> <output directory> <fast-dump path> <trimmomatic path> <adapter_sequence.fa>\t example: perl fastq_preprocessing.pl SRR7971416 /home/anand/Documents/temp/ /home/anand/Downloads/sratoolkit.2.9.2-ubuntu64/bin/fastq-dump /home/anand/Downloads/Trimmomatic-0.38/trimmomatic-0.38.jar /home/anand/Downloads/Trimmomatic-0.38/adapters/TruSeq3-SE.fa\n";
	exit;
	}

my $trimmedFastq="$outDir/$sra_acc/$sra_acc.AT.fastq";
##my $trimmedFastq="$outDir/$sra_acc/$sra_acc.TEMP.fastq";
my $trimmedCollapsedTemp="$outDir/$sra_acc/$sra_acc.AT.COL.TEMP.fa";
my $trimmedCollapsedReHead="$outDir/$sra_acc/$sra_acc.AT.COL.fa";

my $createWD="mkdir -p $outDir/$sra_acc";
my $exec_fastqDump="$fastq_dump $sra_acc -O $outDir/$sra_acc";
my $exec_trimmomatic="java -jar $trimmomatic SE -phred33 $outDir/$sra_acc/$sra_acc.fastq $trimmedFastq ILLUMINACLIP:$adapters:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:25";
my $exec_fastx="fastx_collapser -v -i $trimmedFastq -o $trimmedCollapsedTemp";

print "#### [INFO]\t",scalar(localtime()),"\tProcessing $sra_acc\n\n";
system("$createWD");

print "#### [INFO]\t",scalar(localtime()),"\tDownloading FASTQ file\t$exec_fastqDump\n\n";
system("$exec_fastqDump");

print "\n#### [INFO]\t",scalar(localtime()),"\tStarting adapter removal\t$exec_trimmomatic\n\n";
system("$exec_trimmomatic");

##print "[INFO]\t",scalar(localtime()),"\t$exec_fastx\n";
print "\n#### [INFO]\t",scalar(localtime()),"\tCollapsing reads from $trimmedFastq\n\n";
my $fastxLog=`$exec_fastx`;

#Input: 17285750 sequences (representing 17285750 reads)
#Output: 3873883 sequences (representing 17285750 reads)

my $totalSequences=0;
$fastxLog=~ s/\n/\|/g;
my ($log1,$log2)= split(/\|/,$fastxLog);
my @logSplit=split(/\s/,$log1);
$totalSequences=$logSplit[1];
##$trimmedCollapsedTemp="$outDir/$sra_acc/SRR7971416.trimmed.collapsed.fastq";

if (-e $trimmedCollapsedTemp) {
	open (FA,"$trimmedCollapsedTemp") or die "\n#### [ERROR]\t",scalar(localtime()),"\tCan't open the $trimmedCollapsedTemp file\n";
	open (FAOUT,">$trimmedCollapsedReHead") or die "\n#### [ERROR]\t",scalar(localtime()),"\tCan't write to $trimmedCollapsedReHead file\n";
	my $uniqID="0000001";
	while (my $rec=<FA>) {
		chomp $rec;
		if ($rec=~ /^\>/){
			my ($sn,$count)= split (/\-/,$rec);
			$sn=~ s/\>//g;
			my $normalizedCount=sprintf "%.2f",(($count/$totalSequences)*1000000);
			#my $normalizedCount=($count/$totalSequences)*1000000;
			print FAOUT ">$sra_acc\_$uniqID\_$count\_$normalizedCount\n";
			#print "$uniqID\n";
			$uniqID++;
			}
		else {
			print FAOUT "$rec\n";
			}
		}
	close FA;
	close FAOUT;
	##system("rm $trimmedCollapsedTemp");
	print "#### [INFO]\t",scalar(localtime()),"\tOutput generated: $trimmedCollapsedReHead\n\n";
	}
else {
	print "\n#### [ERROR]\t",scalar(localtime()),"\tNo output generated from fastx_collapser\n";
	}

