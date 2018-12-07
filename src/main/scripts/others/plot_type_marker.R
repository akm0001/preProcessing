##usage: Rscript plot.R /home/anand/Documents/SRA_DUMP/SRR7714773/SRR7714773.blast.out.mod.txt /home/anand/Documents/SRA_DUMP/SRR7714773/ SRR7714773
library(htmlwidgets)
library(ggplot2)
library(plotly)
args <- commandArgs(TRUE)

#fileName<- "/home/anand/Documents/SRA_DUMP/SRR901290/SRR901290.blast.out.mod.txt"
#outDir<- "/home/anand/Documents/SRA_DUMP/SRR901290/"
#srrID<- "SRR901290"
#plotFile<- paste0(outDir,srrID,".jpeg")
 
fileName<- args[1]
outDir<- args[2]
srrID<- args[3]
plotFile<- paste0(outDir,srrID)

blastFull<- read.table(fileName,header = T,sep = "\t")

blastFull$ID<- paste(blastFull$sseqid,blastFull$qseqid, sep="|")

blastFull$Q_Cov<- 100 * (blastFull$nident/blastFull$slen)
newdata <- blastFull[order(blastFull$Q_Cov),] 

p <- 
  plot_ly(
    newdata, 
          x = ~pident, 
          y = ~ID,
          name = 'trace 0',
          type = 'scatter',
          mode = 'markers',
          # Hover text:
          text = ~paste("Identity: ", pident, '<br>Query coverage:', Q_Cov),
          color = ~Q_Cov,
          size = ~Q_Cov
          )%>%
  layout(
    title = paste0(srrID," (Identity and Query coverage)"),
    xaxis = list(
      title = 'Identity'
      ),
    yaxis = list(
      title = 'ID'
      )
    )

p

htmlwidgets::saveWidget(p, file = paste0(outDir,srrID,".html"))
