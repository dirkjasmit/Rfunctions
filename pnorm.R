#!/usr/bin/env Rscript --vanilla

# This script takes a file, extracts a Z column, and caclulates the P value

sink(stderr())

hasheader = T
col = NA

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("pnorm.R is a script to calculate the p-value from a z-value\n")
    cat("  typically, the Z column is pnorm.R is a script to calculate the p-value from a z-value\n")
    cat("  Usage:\n")
    cat("  cat <file> | pnorm.R [-c <column number>]\n")
    return(NULL)
  } 
  v=1
  while (v <= length(args)) {
    if (args[v] == "-c") {
      col = as.numeric(args[v+1])
      v=v+2
    } else if (args[v] == "-h") {
      if (toupper(args[v+1]) %in% c('0','F','FALSE')) {
        hasheader = F
      }
    }
    
  }
}

# read stdin with whitespace delimiter
data <- as.data.frame(data.table::fread('file:///dev/stdin', header=hasheader))

if (is.na(col) && hasheader==F && dim(data)[2]>1) {
  stop('must supply a column number for data with multiple columns and no header')
}

if (is.na(col) || hasheader) {
  ndx = which(toupper(colnames(data)) %in% c('Z','Z_VALUE','Z-VALUE'))
  if (length(ndx)==0) {
    stop('Cannot locate Z column.')
  }
  if (length(ndx)>1) {
    stop('Multiple Z columns found.')
  }
  col = ndx
}

data$P = as.single(pnorm(-abs(data[,col]))*2)

sink(NULL)
write.table(data, file=stdout(), row.names=F, col.names=hasheader, quote=F)





