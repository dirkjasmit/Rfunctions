#!/usr/bin/env Rscript --vanilla

# This script takes a file, extracts a Z column, and caclulates the P value

sink(stderr())

hasheader = T
clustcol = 1
datcol = NULL
na = NULL
filename = 'file:///dev/stdin'

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("opf.R (one-per-family) is a script to select a single member from a cluster, e.g. family\n")
    cat("  either by setting to missing or keeping only randoly selected items in a cluster\n")
    cat("  Usage:\n")
    cat("  cat <file> | opf.R [-c <clust id col num>] [-d <data columns c1,c2,...>] [-n <NA value>]\n")
    cat("  \n")
    cat("  NOTE: is no NA string is defined, the data will be filtered. Otherwise the\n")
    cat("  data will be set to the missing *value* defined (NA, -9, whatever)\n")
    return(NULL)
  } 
  v=1
  while (v <= length(args)) {
    if (args[v] == "-c") {
      clustcol = as.numeric(args[v+1])
      v=v+2
    } else if (args[v] == "-n") {
      if (toupper(args[v+1]) %in% c('NULL')) {
        na=NULL
      } else {
        na=as.numeric(args[v+1])
      }
      v=v+2
    } else if (args[v] == "-d") {
      datcol = as.numeric(strsplit(args[v+1],",")[[1]])
      v=v+2
    } else if (args[v] == "-f") {
      filename = args[v+1]
      v=v+2
    }
  }
}

# read stdin with whitespace delimiter
cat('Reding the data\n')
data <- as.data.frame(data.table::fread(filename, header=hasheader))
cat(sprintf('Read %d lines with %d columns\n',dim(data)[1],dim(data)[2]))

if (!is.null(datcol)) {
  id = data[,clustcol]
  keep = rep(F,length(id))
  u = unique(id)
  hasallNA = rowSums(is.na(data[,datcol]),na.rm=T)==length(datcol)
  hasanyNA = is.na(rowSums(data[,datcol]))
  for (i in 1:length(u)) {
    ndx = id==u[i] & !hasall
    keep[floor(runif(1)*sum(ndx))+1] = T
  }
  data[keep,datcol] = NA
} else {
  id = data[,clustcol]
  keep = rep(F,length(id))
  u = unique(id)
  for (i in 1:length(u)) {
    ndx = id==u[i]
    keep[floor(runif(1)*sum(ndx))+1] = T
  }
  data = data[keep,]
}
cat(sprintf('Keeping %d \n',sum(keep)))

sink(NULL)
write.table(data, file=stdout(), row.names=F, col.names=hasheader, quote=F)





