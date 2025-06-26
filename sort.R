#!/usr/bin/env Rscript --vanilla

# This script takes a SINGLE COLUMN as CHR:BP in the ph3 1KG data and attaches the RS number
# -nh     no header flag (default: fle has header)
# --help  help function
# 
# NOTE make sure the data are whitesapce delimited.

header = F

args = commandArgs(trailingOnly=TRUE)
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("sort.R is a script to sort data numerically ignoring all non-numeric characters,\n")
    cat("  making numeric columns, and sort these by value left to right.\n")
    cat("  Usage: <any command> | sort.R \n")
  }
  if (args[1]=="-h") {
    header = T
  }
}

conn = file("stdin") #stdin() #file('testfile','r')

# read stdin with whitespace delimiter
eof = F
cnt = 0
line = list()
str = list();
mincol = 999999

str = readLines(conn, n=-1)

for (cnt in (1+header):length(str)) {
  tmp = gsub("[^0-9.-]", " ", str[[cnt]])
  oldtmp = ""
  while (nchar(tmp) != nchar(oldtmp)) {
    oldtmp = tmp
    tmp = gsub('  ',' ',tmp,fixed=T)
  }
  tmp = gsub('^ ','',tmp) # leading space
  # print(unlist(lapply(strsplit(tmp," ")[[1]],as.numeric)))
  line = c(line, unlist(lapply(strsplit(tmp," ")[[1]],as.numeric)))
  if (mincol>length(line[[cnt-header]])) {
    mincol = length(line[[cnt-header]])
  }
}


M = matrix(unlist(lapply(line,function(x){return(x[1:mincol])})),ncol=mincol,byrow=T)

for (col in 1:ncol(M)) {
  tmp = M[order(M[,col]),col]
  for (l in 1:length(tmp)) {
    cat(sprintf('%s\n',tmp[l]))
  }
}




 