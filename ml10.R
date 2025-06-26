#!/usr/bin/env Rscript

# This script takes the -log10 value of each column read from stdin
# example usage: cut -d\  -f2,3 file.txt | min.R -h
#   take columns 2 and 3 from file file.txt and report the values, ignore the header


hasheader = F
clean = F

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("min.R is a script to calculate the minimum values in columns of numbers from stdin.\n")
    cat("  Usage: cat <file> | min.R [-h] [-c]\n")
    cat("  -h: input file has header\n")
    cat("  -c: give 'clean' output without row and column names\n")
  } 
  if (args[1] == "-h") {
    hasheader = T
  }
}

data <- read.table(file("stdin"), header=hasheader, sep="", quote="", colClasses=c("numeric"))
# data must be passed as columns with a header
print.matrix <- function(m){
  write.table(format(m, justify="right"), row.names=F, col.names=F, quote=F)
}
print.matrix(-apply(as.matrix(data),2,log10))
