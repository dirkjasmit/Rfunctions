#!/usr/bin/env Rscript --vanilla

# takes the difference between consecutive columns (for each row)

sink(stderr())

require(data.table)

hasheader = T

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("calculate the row-wise difference between consecutive values\n")
    return(NULL)
  } 
}

cat('reading data\n')
# read stdin with whitespace delimiter
data <- as.data.frame(data.table::fread('file:///dev/stdin', header=T))

dataout=data.frame()
for (col in 2:dim(data)[2]) {
  if (is.numeric(data[,col-1]) && is.numeric(data[,col])) {
    dataout = cbind(dataout,data[,col]-data[,col-1])
    colnames(dataout)[dim(dataout)[2]] = sprintf('delta_%s',colnames(data)[col])
  }
}

cat('writing data\n')
sink(NULL)
write.table(dataout, file=stdout(), row.names=F, col.names=T, quote=F)







