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

my $fastaToTabOut= "$outDir/human.hg19.tRna.tab.txt";
my $exec_fasta_formatter= "fasta_formatter -i $tRNARef -t -o $fastaToTabOut";
#print "$exec_fasta_formatter\n";
system ("$exec_fasta_formatter");

my %headerMap=();
open (TAB,"$fastaToTabOut") or die "[ERROR]\t",scalar(localtime()),"\tCan't open the $fastaToTabOut\n";
while (my $tabRow=<TAB>) {
	chomp $tabRow;
	my ($header,$sequence)= split(/\t/,$tabRow);
	my @headerTemp= split(/\s+/,$header);
	my @tag1= split(/\_|\-/,$headerTemp[0]);
	$headerTemp[-1]=~ s/\(|\)//g;
	#print "Hs_$tag1[2].$codonMap{uc $tag1[3]}.$tag1[4]|$headerTemp[-2]|$headerTemp[-1]\t$sequence\n";
	my $mapVals=">Hs_$tag1[2].$codonMap{uc $tag1[3]}.$tag1[4]|$headerTemp[-2]|$headerTemp[-1]";
	if (exists $headerMap{$sequence}) {
		$headerMap{$sequence}= $headerMap{$sequence}."#".$mapVals;
		}
	else {
		$headerMap{$sequence}= $mapVals;
		}
	}

#print Dumper(\%headerMap);
my %seenIDs= ();
my %idsTab=();
foreach my $tempKey (sort keys %headerMap) {
	my @valTemp= split(/\#/,$headerMap{$tempKey});
	my @head= ();
	my @pos= ();
	for (my $i=0;$i<=$#valTemp;$i++) {
		my @info1= split(/\|/,$valTemp[$i]);
		push @head, $info1[0];
		push @pos, "$info1[1]|$info1[2]";
		}
	my %seen1= ();
	my %seen2= ();
	my @uniqueID= grep {!$seen1{$_}++ } @head;
	my @uniquePos= grep {!$seen2{$_}++ } @pos;
	my $idStr= $uniqueID[0];
	$seenIDs{$idStr}= $idStr;
	my $outStr= "$tempKey\t".join("#",@uniquePos);
	if (exists $idsTab{$idStr}) {
		$idsTab{$idStr}= $idsTab{$idStr}."*".$outStr;
		}
	else {
		$idsTab{$idStr}= $outStr;
		}
	}
#print Dumper(\%idsTab);

my $outFasta= "$outDir/human.hg19.tRna.deDup.fa";
my $outMappingTable= "$outDir/human.hg19.tRna.map.txt";

open(OUTFA,">$outFasta") or die "[ERROR]\t",scalar(localtime()),"\tCan't write to $outFasta\n";
open(OUTMAPTAB,">$outMappingTable") or die "[ERROR]\t",scalar(localtime()),"\tCan't write to $outMappingTable\n";


foreach my $tabRec (sort keys %idsTab) {
	my @records= split(/\*/,$idsTab{$tabRec});
	for (my $i=0;$i<=$#records;$i++) {
		my $count=$i+1;
		my ($outSequence,$outPos)= split(/\t/,$records[$i]);
		$records[$i]=~ s/\:/\|/g;
		print OUTMAPTAB "$tabRec.$count\t$records[$i]\n";
		print OUTFA "$tabRec.$count\n$outSequence\n";
		}
	}
