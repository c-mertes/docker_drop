#!R
#
# install correct assembly files
#

args = commandArgs(trailingOnly=TRUE)
if(length(args) == 0){
    print("No assembly data will be installed as non is requested!")
} else {
    
    print(paste("Install assembly for: ", args))
    
    if (!requireNamespace("BiocManager", quietly = TRUE)){
        install.packages("BiocManager")
    }
    
    if(args == "hg19"){
        BiocManager::install("BSgenome.Hsapiens.UCSC.hg19", update=FALSE, ask=FALSE)
    } else if(args == "hg38"){
        BiocManager::install("BSgenome.Hsapiens.UCSC.hg38", update=FALSE, ask=FALSE)
    } else {
        stop(paste("Could not find provided assembly! ", args))
    }
}

