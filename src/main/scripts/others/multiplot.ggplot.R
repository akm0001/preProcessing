library(ggplot2)

blastFull<- read.table("/home/anand/Documents/resources/test.plot.inp.sorted.txt",header = T,sep = "\t")
blastFull$ID<- paste(blastFull$SRR_ID,blastFull$tRNA_ID, sep="|")
# ggplot(blastFull, aes(x=Identity, y=Q_Cov)) +
#   geom_point(colour="red", size=1, shape=20, alpha=1/3) +
#   scale_y_continuous(trans = scales::log10_trans(), breaks = scales::trans_breaks("log10", function(x) 10^x))


blastFiltered<- read.table("/home/anand/Documents/resources/test.plot.inp.2.txt",header = T,sep = "\t")
blastFiltered$ID<- paste(blastFiltered$SRR_ID,blastFiltered$tRNA_ID, sep="|")
# ggplot(blastFiltered, aes(x=Identity, y=Q_Cov)) +
#   geom_point(colour="red", size=1, shape=20, alpha=1/3) +
#   scale_y_continuous(trans = scales::log10_trans(), breaks = scales::trans_breaks("log10", function(x) 10^x))


jpeg('/home/anand/Documents/resources/blastResPlotFiltered.jpeg',width = 1024, height = 768,quality=100)
p1 <- ggplot(blastFiltered, aes(Identity,Q_Cov)) + 
  geom_jitter(alpha = I(1 / 2), aes(color=Q_Cov)) +ggtitle("Query coverage vs Identity (Blastn filtered table)") + theme_bw() + theme(plot.title = element_text(hjust=0.5))
p1 
dev.off()

jpeg('/home/anand/Documents/resources/blastResPlotFull.jpeg',width = 1024, height = 768,quality=100)
p2 <- ggplot(blastFull, aes(Identity,Q_Cov)) + 
  geom_jitter(alpha = I(1 / 2), aes(color=Q_Cov)) + ggtitle("Query coverage vs Identity (Blastn full table)") + theme_bw() + theme(plot.title = element_text(hjust=0.5))
p2 
dev.off()
