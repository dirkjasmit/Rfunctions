#!/usr/bin/env Rscript --vanilla

# this script takes the median value of a column passed via 

hasheader = F

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("corr.R is a script to calculate the median of (a) column(s) of numbers.\n")
    cat("  Usage: cat <file> | median.R [-h]\n")
  } else if (args[1] == "-h") {
    hasheader = T
  }    
}

library(matrixStats)

data <- read.table(file("stdin"), header=hasheader, sep="", quote="", colClasses=c("numeric"))
# data must be passed as columns with a header
print(colMedians(as.matrix(data), na.rm = TRUE))

