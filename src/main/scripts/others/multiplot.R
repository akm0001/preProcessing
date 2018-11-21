library(tidyr)
library(ggplot2)
library(reshape)

blastFull<- read.table("/home/anand/Documents/resources/test.plot.inp.txt",header = T,sep = "\t")
blastTabF<- as.data.frame(unite_(blastFull, "IDs", c("SRR_ID","tRNA_ID"),sep = "|"))
meltDF1<-melt(blastTabF, id.vars = "IDs", measure.vars = c("Identity", "Q_Cov"))

jpeg('/home/anand/Documents/resources/blastResPlotFull.jpeg',width = 1024, height = 768,quality=100)

p1 <- ggplot(data = meltDF1, aes(x = IDs, y = value, group = variable, fill = variable))
p1 <- p1 + geom_bar(stat = "identity", width = 0.5, position = "dodge")
p1 <- p1 + facet_grid(. ~ variable)
p1 <- p1 + theme_bw()
#p <- p + theme(axis.text.x = element_text(angle = 90))
p1
dev.off()

blastFilt<- read.table("/home/anand/Documents/resources/test.plot.inp.2.txt",header = T,sep = "\t")
blastTabFilt<- as.data.frame(unite_(blastFilt, "IDs", c("SRR_ID","tRNA_ID"),sep = "|"))
meltDF2<-melt(blastTabFilt, id.vars = "IDs", measure.vars = c("Identity", "Q_Cov"))

jpeg('/home/anand/Documents/resources/blastResPlotFiltered.jpeg',width = 1024, height = 768,quality=100)

p2 <- ggplot(data = meltDF2, aes(x = IDs, y = value, group = variable, fill = variable))
p2 <- p2 + geom_bar(stat = "identity", width = 0.5, position = "dodge")
p2 <- p2 + facet_grid(. ~ variable)
p2 <- p2 + theme_bw()
#p <- p + theme(axis.text.x = element_text(angle = 90))
p2
dev.off()
