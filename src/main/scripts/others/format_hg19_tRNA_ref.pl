use strict;
use warnings;
#use FindBin qw($Bin);
use Data::Dumper;

my $resources= "/home/anand/Documents/code/src/main/resources/";
#my $scriptDir=$Bin;

my $config= $ARGV[0];

if ((!$config) || (!$resources)) {
	print "[ERROR]\t",scalar(localtime()),"\tUsage: perl format_hg19_tRNA_ref.pl config.txt\n";
	exit;
	}

my ($tRNARef,$codon_tab,$sra_AccList,$outDir)= ();

open (CONF,"$config") or die "[ERROR]\t",scalar(localtime()),"\tCan't open the config file\n";

while (my $cRow=<CONF>) {
	chomp $cRow;
	my @confTemp= split(/\t/,$cRow);
	if ($confTemp[0] eq "tRNA_Ref") { $tRNARef= $confTemp[1]; }
	if ($confTemp[0] eq "Codon_tab") { $codon_tab= $confTemp[1]; }
	if ($confTemp[0] eq "SRA_AccList") { $sra_AccList= $confTemp[1]; }
	if ($confTemp[0] eq "Out_Dir") { $outDir= $confTemp[1]; }
	}
close CONF;

my %codonMap= ();
open (CODON,"$codon_tab") or die "[ERROR]\t",scalar(localtime()),"\tCan't open codon mapping table\n";
while (my $cod=<CODON>) {
	chomp $cod;
	my @codTemp= split(/\t/,$cod);
	$codonMap{uc $codTemp[0]}= $codTemp[1];
	}
close CODON;

my ($outFastaPath,$outMapTablePath)= formatRef($tRNARef,$outDir);
print "[INFO]\t",scalar(localtime()),"\tOutput generated at $outDir\n";





#subroutine to generate non redundant set of tRNA sequences
sub formatRef {
	my ($src,$outPath)= @_;
	open (HG19REF, "$src") or die "[ERROR]\t",scalar(localtime()),"\tCan't open the hg19-tRNAs.fa\n";
	my $tempFile= "$outPath/temp.tRna";

	open (TEMP, ">$tempFile") or die "[ERROR]\t",scalar(localtime()),"\tCan't write to $outPath\n";
	while (my $faRow= <HG19REF>) {
		chomp $faRow;
		my ($header,$seq)= ();
		if ($faRow=~ /^\>/) {
			$header= $faRow;
			print TEMP "\n$header\t";
			}
		else {
			my $seq.= $faRow;
			print TEMP "$seq";
			}
		}

	close HG19REF;
	close TEMP;

	my %seqMapFa= ();
	my %seqMapTable= ();

	if (-e $tempFile) {
		open (TEMP1, "$tempFile");
		my $tempRowHead= <TEMP1>;

		while (my $tempRow= <TEMP1>) {
			chomp $tempRow;
			if ($tempRow=~ /^\s+/){ next; }
			$tempRow=~ s/\s+\(/\|/g; $tempRow=~ s/\)\s+/\|/g; $tempRow=~ s/\:\s+/\:/g; $tempRow=~ s/\s+bp\s+/\_bp\|/g; $tempRow=~ s/\s+/\|/g;
			my @faTemp= split(/\|/,$tempRow);
			my @tag= split(/\-/,$faTemp[0]);

			if (defined $codonMap{uc $tag[1]}) {
				my $faTagStr= ">Hs_tRNA.".$codonMap{uc $tag[1]}.".$tag[2].$tag[3]";
				my $seqMapTableKey= "$faTagStr|$faTemp[-1]";
				my $seqMapTableVal= "$faTemp[-3]:$faTemp[-2]";

				if (exists $seqMapTable{$seqMapTableKey}) {
					$seqMapTable{$seqMapTableKey}= $seqMapTable{$seqMapTableKey}."#".$seqMapTableVal;
					}
				else {
					$seqMapTable{$seqMapTableKey}= $seqMapTableVal;
					}

				if (exists $seqMapFa{$faTemp[-1]}) {
					$seqMapFa{$faTemp[-1]}= $seqMapFa{$faTemp[-1]}."|".$faTagStr;
					}
				else {
					$seqMapFa{$faTemp[-1]}= $faTagStr;
					}
				}

			else {
				print "[ERROR]\t",scalar(localtime()),"\tUnidentified AA code at $tempRow\n";
				}
			}

		close TEMP1;

		my $outFasta= "$outPath/human.hg19.tRna.deDup.fa";
		my $outMappingTable= "$outPath/human.hg19.tRna.map.txt";

		open(OUTFA,">$outFasta") or die "[ERROR]\t",scalar(localtime()),"\tCan't write to $outFasta\n";
		open(OUTMAPTAB,">$outMappingTable") or die "[ERROR]\t",scalar(localtime()),"\tCan't write to $outMappingTable\n";

		foreach my $seqKey(sort keys %seqMapFa) { #to generate the reference fasta file
			my @seqIdsArr= split(/\|/,$seqMapFa{$seqKey});
			my %seen= ();
			my @unique= grep {!$seen{$_}++ } @seqIdsArr;
			print OUTFA join("|",@unique),"\n$seqKey\n";
			}

		foreach my $seqTabKey(sort keys %seqMapTable) { #to generate the reference mapping table
			my ($tabID,$tabSeq)= split (/\|/,$seqTabKey);
			my @seqIdsTabArr= split(/\#/,$seqMapTable{$seqTabKey});
			my %seen1= ();
			my @uniqueTab= grep {!$seen1{$_}++ } @seqIdsTabArr;
			print OUTMAPTAB "$tabID\t$tabSeq\t",join("|",@uniqueTab),"\n";
			}

		close OUTFA;
		close OUTMAPTAB;

		system("rm $outPath/temp.tRna");
		return($outFasta,$outMappingTable);
		}

	else {
		print "[ERROR]\t",scalar(localtime()),"\tUnable to parse the reference fasta file\n";
		}
	}
