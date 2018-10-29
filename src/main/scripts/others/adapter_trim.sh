FASTQ=$1
ID=$2
OUT=$3

java -jar /home/anand/Downloads/Trimmomatic-0.38/trimmomatic-0.38.jar SE -phred33 $FASTQ $OUT/$ID.trimmed.fq.gz ILLUMINACLIP:/home/anand/Downloads/Trimmomatic-0.38/adapters/TruSeq2-SE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:25
