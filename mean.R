#!/usr/bin/env Rscript --vanilla

# This script takes the mean value of each column read from stdin
# example usage: cut -d\  -f2,3 file.txt | min.R -h
#   take columns 2 and 3 from file file.txt and report the mean values, ignore the header


hasheader = F

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("min.R is a script to calculate the minimum values in columns of numbers from stdin.\n")
    cat("  Usage: cat <file> | min.R [-h]\n")
  } else if (args[1] == "-h") {
    hasheader = T
  }
}

data <- read.table(file("stdin"), header=hasheader, sep="", quote="", colClasses=c("numeric"))
# data must be passed as columns with a header
print(apply(as.matrix(data),2,mean,na.rm=T))

