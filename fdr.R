#!/usr/bin/env Rscript --vanilla

# This script outputs the FDR corrected p-value 
# example usage: cat file.txt | fdr.R -h -c 2
#   prints the file with the fdr


hasheader = F
colnum = 1
printfull = F

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error

if (length(args)>0) {
  if (args[1]=="--help") {
    cat("fdr.R is a script to calculate the fdr p-values of a column of numbers from stdin.\n")
    cat("  Usage: cat <file> | fdr.R [-h -f] [-c colnum]\n")
    quit()
  }
  skipnext=F
  for (v in 1:length(args)) {
    # cat(args[v], file=stderr())
    if (skipnext) {
      skipnext=F
      next
    }
    if (args[v] == "-h") {
      hasheader = T
    } else if (args[v] == "-f") {
      printfull = T
    } else if (args[v] == "-c") {
      colnum = as.numeric(args[v+1])
      skipnext=T
    } else {
      error('Invalid argument to fdr.R')
    }
  }
}

data <- read.table(file("stdin"), header=hasheader, sep="", quote="")
# data may be passed as columns with a header. apply -h to skip this header.

# access p-values as list
p = data[,colnum]
p_fdr = stats::p.adjust(p,method='BH')
if (printfull) {
  tmp = cbind(data,p_fdr)
  colnames(tmp) = c(colnames(data),'FDR')
  write.table(tmp,row.names=F,col.names=hasheader,quote=F)
} else {
  tmp = cbind(p_fdr)
  colnames(tmp) = 'FDR'
  write.table(tmp,row.names=F,col.names=hasheader,quote=F)
}

