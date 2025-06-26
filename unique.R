#!/usr/bin/env Rscript --vanilla

# This script takes a file, extracts a Z column, and caclulates the P value

sink(stderr())

hasheader = T
col = 1

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("pnorm.R is a script to calculate the p-value from a z-value\n")
    cat("  typically, the Z column is pnorm.R is a script to calculate the p-value from a z-value\n")
    cat("  Usage:\n")
    cat("  cat <file> | pnorm.R [-c <column number>] [--no-header]\n")
    return(NULL)
  } 
  v=1
  while (v <= length(args)) {
    if (args[v] == "-c") {
      col = as.numeric(args[v+1])
      v=v+2
    } else if (args[v] == "--no-header") {
      hasheader = F
      v=v+1
    }
  }
}

# read stdin with whitespace delimiter
data <- as.data.frame(data.table::fread('file:///dev/stdin', header=hasheader))

if (is.na(col) && hasheader==F && dim(data)[2]>1) {
  stop('must supply a column number for data with multiple columns and no header')
}

sink(NULL)
out_data = as.data.frame(unique(data[,col]))
if (hasheader) {
  colnames(out_data)[1] = colnames(data)[col]
  write.table(out_data, file=stdout(), row.names=F, col.names=T, quote=F)
} else {
  write.table(out_data, file=stdout(), row.names=F, col.names=F, quote=F)
} 





