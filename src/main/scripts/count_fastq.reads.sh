FASTQ=$1 #my.fastq.gz
#zcat my.fastq.gz | echo $((`wc -l`/4))
zcat $FASTQ | echo $((`wc -l`/4))
