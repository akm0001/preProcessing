library(plotly)

blastFull<- read.table("/home/anand/Documents/resources/test.plot.inp.sorted.txt",header = T,sep = "\t")
blastFull$ID<- paste(blastFull$SRR_ID,blastFull$tRNA_ID, sep="|")
p <- plot_ly(blastFull) %>%
  add_trace(x= ~ID, y= ~Q_Cov, type='bar', name='Q Coverage',
            marker=list(color = '#C9EFF9'),
            hoverinfo= "text",
            text=~ paste('Q:',Q_Cov)) %>%
  add_trace(x= ~ID, y= ~Identity, type= 'scatter', mode= 'markers',name= 'Identity', yaxis= 'y2',
            hoverinfo = "text",
            text= ~paste('I:',Identity,'%')) %>%
  layout(title = 'Query coverage vs Identity (Blastn full table)',
         xaxis = list(title = ""),
         yaxis = list(side = 'left', title = 'Query coverage', showgrid = FALSE, zeroline = FALSE),
         yaxis2 = list(side = 'right', overlaying = "y", title = 'Identity', showgrid = FALSE, zeroline = FALSE))
p

##add_trace(x= ~ID, y= ~Q_Cov, type= 'scatter', mode= 'lines', line = list(dash='dot', width = 1),name= 'Query coverage', yaxis= 'y2',
#line = list(color = '#45171D'),


blastFiltered<- read.table("/home/anand/Documents/resources/test.plot.inp.2.txt",header = T,sep = "\t")
blastFiltered$ID<- paste(blastFiltered$SRR_ID,blastFiltered$tRNA_ID, sep="|")
p2 <- plot_ly(blastFiltered) %>%
  add_trace(x= ~ID, y= ~Q_Cov, type='bar', name='Q Coverage',
            marker=list(color = '#C9EFF9'),
            hoverinfo= "text",
            text=~ paste('Q:',Q_Cov)) %>%
  add_trace(x= ~ID, y= ~Identity, type= 'scatter', mode= 'markers',name= 'Identity', yaxis= 'y2',
            hoverinfo = "text",
            text= ~paste('I:',Identity,'%')) %>%
  layout(title = 'Query coverage vs Identity (Blastn filtered table)',
         xaxis = list(title = ""),
         yaxis = list(side = 'left', title = 'Query coverage', showgrid = FALSE, zeroline = FALSE),
         yaxis2 = list(side = 'right', overlaying = "y", title = 'Identity', showgrid = FALSE, zeroline = FALSE))
p2
