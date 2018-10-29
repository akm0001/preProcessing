use strict;
use warnings;
use FindBin qw($Bin);

my $scriptDir=$Bin;
my $config=$ARGV[0];

if (!$config){
	print "[ERROR]\t",scalar(localtime()),"\tUsage: perl batch.wrapper.pl /home/anand/Documents/preProcessing/src/main/resources/wrapper.config.txt\n";
	exit;
        }

open (CONF,"$config") or die "[ERROR]\t",scalar(localtime()),"\tCan't open the config file\n";

my($sra_AccList,$outDir,$fastqDump,$trimmomatic,$adapters)=();

while (my $cRow=<CONF>) {
	chomp $cRow;
	my @confTemp= split(/\t/,$cRow);
	if ($confTemp[0] eq "SRA_AccList") { $sra_AccList= $confTemp[1]; }
	if ($confTemp[0] eq "Out_Dir") { $outDir= $confTemp[1]; }
	if ($confTemp[0] eq "Fastq-dump") { $fastqDump= $confTemp[1]; }
	if ($confTemp[0] eq "Trimmomatic") { $trimmomatic= $confTemp[1]; }
	if ($confTemp[0] eq "Adapters") { $adapters= $confTemp[1]; }
	}
close CONF;

print "#### [INFO] ", scalar localtime (),"\t#CONFIG#\t$config\n";

open (SRA, "$sra_AccList") or die "#### [ERROR]\t",scalar(localtime()),"\tcan't open the file with SRA accession IDs\n";
while (my $sraID=<SRA>){
	chomp $sraID;
	my $processCmd="perl $scriptDir/fastq_preprocessing.pl $sraID $outDir $fastqDump $trimmomatic $adapters";
	print "#### [INFO] ", scalar localtime (),"\t#SCRIPT#\t$processCmd\n";
	system ("$processCmd");
	}
