#################
# Title: operon_excel_from_graph_python.R-
# Author- Renee Oles
# Purpose: R Script to summarize the paths from the graph.py program
# Output: An excel file summarizing all the possible paths from the graph traversal program
# Date- 9/23/2022
################
# Load libraries
library(tidyverse)
library(openxlsx)
library(dplyr)
library(pheatmap)

# Needed files
# genes anno is the result of merging roary output with eggnog 
genes_anno <- genes_anno_d2
# genes phylo is from a custom script which summarizes the number of samples in each phylogroup that have a gene
genes_phylo <- genes_phylo_d2

#The name should be the prefix before "path.csv" which is the output from the graph traversal python program 
name <- "Operons/t6ss/d2/group_11049"
description <- data.frame()
names <- data.frame()

# read in the path csv file
operon1 <- read.csv(paste(name,"path.csv",sep=""), header = F)
# edit the csv file
operon1 <- t(operon1[,-1])
operon1 <- apply(operon1, 2, function(x){gsub('\'','',x)})
operon1 <- apply(operon1, 2, function(x){gsub('\\]','',x)})
operon1 <- apply(operon1, 2, function(x){gsub('\\[','',x)})
operon1 <- apply(operon1, 2, trimws)

# create an excel workbook
wb <- createWorkbook(paste(name,".xlsx",sep=""))
for (i in 1:ncol(operon1)){
  o_temp <- as.data.frame(operon1[,i])
  #colnames(o_temp) <- "d2"
  #o_temp <- left_join(o_temp,div_comp[,c(1:2)])
  colnames(o_temp) <- "panaroo_group"
  #colnames(o_temp)[2] <- "panaroo_group"
  # left join with genes anno to get a description of each of the genes
  o_temp <- left_join(o_temp,genes_anno)
  # doulbe check that this part is correct if something weird is happening
  o_temp <- o_temp[,c(1,4,5,3,23,36,22,24,17)]
  # get rid of any duplicates, right now not selecting based off a factor
  o_temp <- o_temp[!duplicated(o_temp$panaroo_group), ]
  # join genes phylo which is the number of samples per phylogroup that have that gene 
  o_temp <- left_join(o_temp,genes_phylo)
  name1 <- paste("path",i,sep="")
  addWorksheet(wb,name1)
  writeDataTable(wb,i,o_temp)
  write.table(o_temp$panaroo_group,paste(paste(name,name1,sep=""),".txt",sep=""),row.names = F, quote=F)
  desc_temp <- o_temp$Description
  length(desc_temp) <- 40
  desc_temp <- data.frame(desc_temp)
  colnames(desc_temp)=paste("path",i,sep="")
  if(dim(description) == 0){
    description <- desc_temp
  }
  else{
    description <- bind_cols(description,desc_temp)
  }
}
addWorksheet(wb,"Descrption")
writeDataTable(wb,i+1,description)
saveWorkbook(wb, file = paste(name,".xlsx",sep=""), overwrite = TRUE)

