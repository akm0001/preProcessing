library(ggplot2)
library(grid)
library(dplyr)
library(grid)

par(mfrow=c(1,2))
blastFull<- read.table("/home/anand/Documents/resources/test.plot.inp.txt",header = F,sep = "\t")
blastFiltered<- read.table("/home/anand/Documents/resources/test.plot.inp.2.txt",header = F,sep = "\t")

# Compute the density data
densPlotFull <- density(blastFull$V5)
# plot density
plot(densPlotFull, frame = FALSE, col = "steelblue", main = "Blastn (full)") 

densPlotFiltered <- density(blastFiltered$V5)
# plot density
plot(densPlotFiltered, frame = FALSE, col = "steelblue", main = "Blastn (filtered)") 


