#!/usr/bin/env Rscript

# this script takes the GRM file in argument, reads the GRM data
# makes the offdiagonal values zero, and saves the GRM with 
# suffix _Ident

hasheader = F

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("corr.R is a script to calculate the correlation between columns of numbers.\n")
    cat("  Usage: cat <file> | corr.R [-h]\n")
  } else if (args[1] == "-h") {
    hasheader = T
  }    
}

data <- read.table(file("stdin"), header=hasheader, sep="", quote="", colClasses=c("numeric"))
# data must be passed as columns with a header
print(cor(as.matrix(data),use="pairwise.complete.obs"))

