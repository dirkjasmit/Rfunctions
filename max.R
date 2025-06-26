#!/usr/bin/env Rscript --vanilla

# This script takes the maxmimum value of each column read from stdin
# example usage: cut -d\  -f2,3 file.txt | min.R -h
#   take columns 2 and 3 from file file.txt and report the minimum values, ignore the header


hasheader = F
returnindex = F
columns = NA

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
i=0
while (i<length(args)) {
  i = i + 1
  if (args[i]=="--help") {
    cat("min.R is a script to calculate the minimum values in columns of numbers from stdin.\n")
    cat("  Usage: cat <file> | min.R [-h]\n")
  } else if (args[i] == "-h") {
    hasheader = T
  } else if (args[i] == "-i") {
    returnindex = T
  } else if (args[i] == "-c") {
    i = i + 1
    columns = eval(args[i])
  }
}

data <- read.table(file("stdin"), header=hasheader, sep="", quote="")
#head(data)
#cn=colnames(data)
#tmp = eval(parse(text=sprintf('data$%s',cn[1])))
#print(as.numeric(tmp[1:10]))

if (is.na(columns)) {
  columns = 1:dim(data)[2]
}

# data must be passed as columns with a header
cat(apply(as.matrix(data[,columns]),2,max,na.rm=T))
cat('\n')
