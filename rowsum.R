#!/usr/bin/env Rscript --vanilla

# takes the difference between consecutive columns (for each row)

sink(stderr())

require(data.table)

hasheader = T

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("calculate the row-wise sum\n")
    cat("  flags\n")
    cat("  -n: no header line\n")
    return(NULL)
  } else if (args[1]=="-n") {
    hasheader=F
  }
  
}

cat('reading data\n')
# read stdin with whitespace delimiter
data <- as.data.frame(data.table::fread('file:///dev/stdin', header=hasheader))

dataout=data.frame(sum=rowSums(as.matrix(data), na.rm=T))
cat('writing data\n')
sink(NULL)
write.table(dataout, file=stdout(), row.names=F, col.names=T, quote=F)








