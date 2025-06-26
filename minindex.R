#!/usr/bin/env Rscript --vanilla

# This script takes the minimum value of each column read from stdin
# example usage: cut -d\  -f2,3 file.txt | min.R -h
#   take columns 2 and 3 from file file.txt and report the minimum values, ignore the header

sink('/dev/null')

hasheader = F
colnum = 1;

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error

if (length(args)>0) {
  # cat(sprintf("number of args: %d\n",length(args)))
  
  if (args[1]=="--help") {
    sink()
    cat("min.R is a script to calculate the minimum values in columns of numbers from stdin.\n")
    cat("  Usage: cat <file> | min.R [-h -i]\n")
    quit()
  }
  for (v in 1:length(args)) {
    # cat(args[v], file=stderr())
    if (args[v] == "-h") {
      hasheader = T
    } else if (args[v]=='-c') {
      v = v + 1;
      colnum = as.numeric(args[v]);
    }
  }
}

# read data as table with whitespace separators
data <- read.table(file("stdin"), header=hasheader, sep="", quote="")
# data must be passed as columns with a header
L = apply(as.matrix(data), 2, which.min)
#print(L)
#print(class(L))
sink()
if (is.list(L)) {
  cat(sprintf('%d',L[[1]]))
  for (l in 2:length(L)) {
    cat(sprintf(' %d',L[[l]]))
  }
  cat('\n')
} else {
  cat(sprintf('%d\n',L))
}


