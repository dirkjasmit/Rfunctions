#!/usr/bin/env Rscript

# this script takes a column of data and plots a histgram in a png file

hasheader = F

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("hist.R is a script to plot a histogram from a column of data\n")
    cat("  Usage: cat <file> | hist.R [-h]\n")
    cat("         cut -f1 <file> | hist.R [-h]\n")
  } else if (args[1] == "-h") {
    hasheader = T
  }    
}

library(matrixStats)

data <- read.table(file("stdin"), header=hasheader, sep="", quote="", colClasses=c("numeric"))
# data must be passed as columns with a header
png('hist.R.png',width=5,height=5,units='in',res=300,type='cairo')
if (!is.numeric(data[,1])) {
  hist(as.numeric(data[,1]),breaks=max(round(sqrt(dim(data)[1])),10))
} else {
  hist(data[,1],breaks=max(round(sqrt(dim(data)[1])),10))
}
dev.off()
