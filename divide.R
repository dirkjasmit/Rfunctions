#!/usr/bin/env Rscript --vanilla

# this script divides two columns. Pass -h to indicate there is a header. Pass
# -n to specify the new column name

hasheader = F
name = 'div'

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
for (v in 1:length(args)) {
  if (args[1]=="--help") {
    cat("corr.R is a script to calculate the median of (a) column(s) of numbers.\n")
    cat("  Usage: cat <file> | median.R [-h]\n")
    v=v+1
    return(0)
  } else if (args[v] == "-h") {
    v=v+1
    hasheader = T
  } else if (args[v] == "-n") {
    name = args[v+1]
    v=v+2
  }    
}

library(matrixStats)

data <- read.table(file("stdin"), header=hasheader, sep="", quote="", colClasses=c("numeric"))
# data must be passed as columns with a header
tmp = as.matrix(data[,1]/data[,2])
colnames(tmp) = name
write.table(tmp, file="", col.names=hasheader,quote=F,row.names=F)

