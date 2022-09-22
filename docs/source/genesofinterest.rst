Analyze and summarize genes of interest
=============

In this tutorial we start with a gene presence absence file from roary or panaroo and use R to create a summary of gene presence absence based off metadata of interest 


.. code-block:: r

    # Read in the file
    genes <- read.csv("gene_presence_absence.csv", header=TRUE, fill=TRUE, check.names = FALSE)


.. code-block:: r

    # Create a function that will find each gene of interest and add it to your matrix
    add_gene <- function(gene_name,new_name){
        if(gene_name %in% genes[,1]){fragilysin <- genes[genes[,1] == gene_name,]}
        else{fragilysin <- genes[genes$Annotation %like% gene_name,]}
        fragilysin[fragilysin == ""] <- 0
        rownames(fragilysin) <- fragilysin[,1]
        fragilysin <- fragilysin[,c(15:ncol(fragilysin))]
        fragilysin[fragilysin != 0] <- 1
        fragilysin <- mutate_all(fragilysin, function(x) as.numeric(as.character(x)))
        frag_sum <- as.data.frame(colSums(fragilysin))
        colnames(frag_sum)[1] <- rownames(fragilysin)[1]
        frag_sum$Sample <- rownames(frag_sum)
        if(nrow(fragilysin)> 1){
            frag_sum <- cbind(frag_sum, t(fragilysin))
            colnames(frag_sum)[1] <- new_name
        }
    return(frag_sum)
    }

.. code-block:: r 

    # Use the function to create the matrix based off your genes of interest
    key <- read.table("key.txt",header=T)
    # Where the text file "key.txt" should have the first column be the genes of interest labeled however you like and the second column should match the the ID of the gene in the presence/absence file or should match part of the annotation column
    blitz <- data.frame()
    for(i in 1:nrow(key)){
        gene <- add_gene(key[i,2],key[i,1])
        if(nrow(blitz)==0){blitz <- gene[,c(2,1)]}
        else{blitz <- left_join(blitz,gene)}
    }

If you would like to summarize the data by metadata

TODO: Generalize

.. code-block:: r

    counts_per_group <- function(b){
        gof_genes <- left_join(groups[,c(1:3,5,11)],b)
        gof_counts <- as.data.frame(t(na.omit(gof_genes[,-c(2:5)])%>%group_by(Division)%>%summarise_all(funs(sum))))
        gof_counts <- cbind(gof_counts,as.data.frame(t(na.omit(gof_genes[,-c(1:3,5)])%>%group_by(Group)%>%summarise_all(funs(sum)))))
        gof_counts <- cbind(gof_counts,as.data.frame(t(na.omit(gof_genes[,-c(1:2,4:5)])%>%group_by(Source_mod)%>%summarise_all(funs(sum)))))
    
        colnames(gof_counts) <- gof_counts[1,]
        gof_counts <- gof_counts[-1,]
        colnames(gof_counts)[3] <- "unknown"
        colnames(gof_counts)[8] <- "unknown_site"
        gof_counts <- mutate_all(gof_counts, function(x) as.numeric(as.character(x)))
        gof_counts$panaroo_group <- rownames(gof_counts)
        colnames(gof_counts)[1:2] <- c(2,1)
        counts <-c(143,544,373,10,50,207,13,374,115,44,43,45)
        for(i in 1:length(counts)){
            gof_counts[,i] <- gof_counts[,i]/counts[i]
        }
        names <- colnames(b)
        names <- connections[connections$panaroo_group %in% names,c(1,2)]
        blitz_eggnog <- left_join(names, eggnog)
        gof_counts <- left_join(gof_counts,blitz_eggnog)
        gof_counts <- right_join(key,gof_counts)
    }
    gof_counts <- counts_per_group(blitz)

