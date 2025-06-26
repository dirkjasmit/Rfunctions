#!/usr/bin/env Rscript --vanilla

# This script takes the minimum value of each column read from stdin
# example usage: cut -d\  -f2,3 file.txt | min.R -h
#   take columns 2 and 3 from file file.txt and report the minimum values, ignore the header


hasheader = F
index = F

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error

if (length(args)>0) {
  if (args[1]=="--help") {
    cat("min.R is a script to calculate the minimum values in columns of numbers from stdin.\n")
    cat("  Usage: cat <file> | min.R [-h -i] [-c colnum]\n")
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
    } else if (args[v] == "-i") {
      index = T
    } else if (args[v] == "-c") {
      colnum = as.numeric(args[v+1])
      skipnext=T
    } else {
      error('Invalid argument to min.R')
    }
  }
}

data <- read.table(file("stdin"), header=hasheader, sep="", quote="", colClasses=c("numeric"))
# data must be passed as columns with a header
if (index) {
  print(apply(as.matrix(data), 2, which.min))
} else {
  print(apply(as.matrix(data), 2, min, na.rm=T))
}

