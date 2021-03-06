### USAGE ###
# EXAMPLE:
# Rscript ./code/scripts-compartments-fixSignSelected.r ./results/compartments.by_group.homer.res_100kb/filter.by_sample.mapq_20/align.by_sample.bowtie2/fadu-WT/ chr3,chr17

argv = commandArgs(trailingOnly = TRUE)
samplePath = argv[1L] #bedgraph file where to apply the chromosome pc1 sign inversion/s
chromsList = argv[2L] #comma separeted list of the chromosomes to be flipped

chromsToFlip=unlist(strsplit(chromsList,split = ","))
bedgraph=read.csv(paste0(samplePath,"/compartments.scores.bedGraph"),sep="\t",header = F,stringsAsFactors = F,col.names = c("chr","start","end","pc1"))
write.table(bedgraph,paste0(samplePath,"/compartments.scores_old.bedGraph"),quote = F,col.names = F,row.names = F,sep="\t")

bedgraph$pc1[bedgraph$chr %in% chromsToFlip]=bedgraph$pc1[bedgraph$chr %in% chromsToFlip]*-1
write.table(bedgraph,paste0(samplePath,"/compartments.scores.bedGraph"),quote = F,col.names = F,row.names = F,sep="\t")

compartmentsA=read.csv(paste0(samplePath,"/A_compartments.bed" ),sep="\t",header = F,stringsAsFactors = F,col.names = c("chr","start","end"))
compartmentsB=read.csv(paste0(samplePath,"/B_compartments.bed" ),sep="\t",header = F,stringsAsFactors = F,col.names = c("chr","start","end"))
write.table(compartmentsA,paste0(samplePath,"/A_compartments_old.bed"),quote = F,col.names = F,row.names = F,sep="\t")
write.table(compartmentsB,paste0(samplePath,"/B_compartments_old.bed"),quote = F,col.names = F,row.names = F,sep="\t")

compartmentsA_toFlip=compartmentsA[compartmentsA$chr %in% chromsToFlip,]
compartmentsB_toFlip=compartmentsB[compartmentsB$chr %in% chromsToFlip,]
compartmentsA_fix = compartmentsA[!compartmentsA$chr %in% chromsToFlip,]
compartmentsB_fix = compartmentsB[!compartmentsB$chr %in% chromsToFlip,]
compartmentsA_fix=rbind(compartmentsA_fix,compartmentsB_toFlip)
compartmentsB_fix=rbind(compartmentsB_fix,compartmentsA_toFlip)
suppressWarnings({compartmentsA_fix=compartmentsA_fix[order(as.numeric(gsub(compartmentsA_fix$chr,pattern = "chr",replacement = "")),compartmentsA_fix$start),]})
suppressWarnings({compartmentsB_fix=compartmentsB_fix[order(as.numeric(gsub(compartmentsB_fix$chr,pattern = "chr",replacement = "")),compartmentsB_fix$start),]})
write.table(compartmentsA_fix,paste0(samplePath,"/A_compartments.bed"),quote = F,col.names = F,row.names = F,sep="\t")
write.table(compartmentsB_fix,paste0(samplePath,"/B_compartments.bed"),quote = F,col.names = F,row.names = F,sep="\t")

print("Done!")
print(paste0("The PC1 sign of ",chromsList," has been inverted."))
print("The 'compartments.scores.bedGraph' file has been replaced with a version that incorporates those changes")
print("The previous 'compartments.scores.bedGraph' file has been saved as 'compartments.scores_old.bedGraph'")
print("The 'A_compartments.bed' file has been replaced with a version that incorporates those changes")
print("The 'B_compartments.bed' file has been replaced with a version that incorporates those changes")
print("The previous 'A_compartments.bed' has been saved as 'A_compartments_old.bed'")
print("The previous 'B_compartments.bed' has been saved as 'B_compartments_old.bed'")
print("If you already ran the compartments-stats step, please re-run it get the updated stats")
