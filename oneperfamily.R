#!/usr/bin/env Rscript --vanilla

# This script takes a file, extracts a Z column, and caclulates the P value

sink(stderr())

hasheader = T

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("oneperfamily.R is a script to select data so that only one subject per cluster remains\n")
    cat("- input:  pass two columns of data: \n")
    cat("          family-ID and data (NA is missing)\n")
    cat("- output: the same data with selected values set to NA\n\n")
    cat("Usage:\n")
    cat("  cat <file> | oneperfamily.R\n")
    return(NULL)
  } 
  v=1
  while (v <= length(args)) {
    if (args[v] == "--no-header") {
      hasheader = F
      v=v+1
    }
  }
}

# read stdin with whitespace delimiter
data <- as.data.frame(data.table::fread('file:///dev/stdin', header=hasheader))

done = rep(F,nrow(data))
for (row in 1:nrow(data)) {
  if (!done[row]) {
    ndx = which(data[,1]==data[row,1] & !is.na(data[,2]))
    
    if (length(ndx)>1) {
      rnd = sample(ndx)
      data[rnd[2:length(rnd)],2] = NA
    }
    # sign all as done
    done[data[,1]==data[row,1]] = T
  }
}

sink(NULL)

if (hasheader) {
  write.table(data, file=stdout(), row.names=F, col.names=T, quote=F)
} else {
  write.table(data, file=stdout(), row.names=F, col.names=F, quote=F)
} 





