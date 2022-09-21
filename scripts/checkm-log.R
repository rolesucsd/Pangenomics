#################
# Check.R- program to load checkM results from one file and graph
# Author- Renee Oles
# Date- 7/2/2021
################

#install.packages("broom",repos = "https://cloud.r-project.org")
#install.packages("plyr",repos = "https://cloud.r-project.org")
#install.packages("tidyverse",repos = "https://cloud.r-project.org")
#install.packages("reshape2",repos = "https://cloud.r-project.org")
#install.packages("ggplot2",repos = "https://cloud.r-project.org")
require(tidyverse)
args <- commandArgs(trailingOnly = TRUE)
inarg <- args
meta <- "metadata/groups.txt"
output <- "../Isoqual/checkm_log"

file.create(paste(output,".txt",sep=""))
processFile = function(input) {
  con = file(input, "r")
  while ( TRUE ) {
    line = readLines(con, n = 1)
    if ( length(line) == 0 ) {
      break
    }
    else if (grepl("---", line)){
      while ( TRUE ) {
        line = readLines(con, n = 1)
        if ( length(line) == 0 ) {
          break
        }
        if(!grepl("Bin",line) && !grepl("---",line) & !grepl("\\[",line)){
          input <- gsub("../Assembly/Shovill/","",input)
          input <- gsub("/lineage.log","",input)
          line <- gsub("filter", input, line)
          write(line, file=paste(output,".txt",sep=""), append=TRUE)
        }
      }
    }
  }
  close(con)
}
for(i in inarg){processFile(i)}

# LOAD DATA
checkm_r <- data.frame()
df_c <- read.table(paste(output,".txt",sep=""), header=FALSE, sep="\t")
#df_c$old_sample_name <- as.numeric(substr(df_c$Sample,1,9))
colnames(df_c)[1] <- "first"
df_c <- separate(df_c, first,sep=("\\s+"), into=c("Blank","Bin_ID","Marker_lineage","Marker_lineage_ID","genomes","markers","marker_sets","0","1","2","3","4","5+","Completeness","Contamination","Strain_heterogeneity"))
df_c <- df_c[,c(2,3,14,15,16)]
write.table(df_c, paste(output,".txt",sep=""), quote=FALSE,row.names = FALSE,col.names = TRUE,sep="\t")
df_c$Contamination <- as.numeric(df_c$Contamination)
df_c$Completeness <- as.numeric(df_c$Completeness)
write.table(df_c[df_c$Contamination < 5 & df_c$Completeness > 95 ,1], paste(output,"_filter.txt",sep=""), quote=FALSE,row.names = FALSE,col.names = FALSE,sep="\t")
colnames(df_c)[1] <- "Sample"
metadata <- read.table(meta, header=TRUE, sep="\t")
df_c <- left_join(df_c, metadata)

# plot the log file with all three variables in the same same graph
require(reshape2)
print("good")
data_long <- melt(df_c, id=c("Sample","Marker_lineage","Group_num","Group"))  # convert to long format
data_long$value <- as.numeric(data_long$value)

require(ggplot2)
ggplot(data_long, aes(fill=variable, x=value))+
  geom_histogram(bins=20)+
  theme_classic()+
  ggtitle("CheckM")+
  xlab("Isolates")+
  ylab("")+
  theme(axis.text.x = element_blank(), legend.position="none")+
#  scale_fill_brewer(type = "div", palette = "Spectral") +
#  scale_fill_manual(values=c("#c6690c","#62b587","#664697","black"))+
  facet_wrap(~Group_num, nrow=3, scales="free")
ggsave(paste(output,".png",sep=""), height=8,width=8)

