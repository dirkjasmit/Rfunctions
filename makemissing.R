#!/usr/bin/env Rscript

# this script takes a column of data and plots a histgram in a png file

sink(file=stderr())

hasheader = F
low = NA
upp = NA
vals = NA
sep=""

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("makemissing.R is a script to remove specific values or ranges of values FROM A SINGLE COLUMN\n")
    cat("  Usage: cat <file> | hist.R [-h] [-l min] [-u max] [-v val1,val2,...]\n")
    cat("         cut -f1 <file> | hist.R [-h] [-l min] [-u max] [-v val1,val2,...]\n")
    return()
  }
  
  # fall thru
  for (v in 1:length(args)) {
    if (args[v] == "-h") {
      hasheader = T
    } else if (args[v]=='-r') {
      tmp = as.numeric(strsplit(args[v+1],',')[[1]])
      print(tmp)
      low = tmp[1]
      upp = tmp[2]
    } else if (args[v]=='-l') {
      low = as.numeric(args[v+1])
    } else if (args[v]=='-l') {
      upp = as.numeric(args[v+1])
    } else if (args[v]=='-v') {
      vals = as.numeric(strsplit(args[v+1],',')[[1]])
    } else if (args[v]=='-s') {
      sep = args[v+1]
    }
  }
}

print(low)
print(upp)
print(is.numeric(low))

if (nchar(sep)==0) {
  data <- data.table::fread('file:///dev/stdin', header=hasheader, quote="", colClasses=c("numeric"))
} else {
  data <- data.table::fread('file:///dev/stdin', header=hasheader, sep=sep, quote="", colClasses=c("numeric"))
}
# data must be passed as columns with a header

# data columns can be accessed as list items. Make sure it is 
# a numeric column.
if (class(data[[1]])!='numeric') {
  data[[1]] = as.numeric(data[[1]])
}

# now determine which items to output
ndx = matrix(TRUE,dim(data)[1],1);
if (!is.na(low)) {
  ndx[data<low] = FALSE
}
if (!is.na(upp)) {
  ndx[data>upp] = FALSE
}
if (length(vals)>1 || !is.na(vals)) {
  ndx = (data %in% vals)
}
# ndx holds TRUE for data to KEEP. make !ndx missing

print(length(data[[1]]))
print(dim(data))
data[!ndx] = NA

# output the data
sink()
write.table(data,file=stdout(),quote=F,row.names=F,col.names=T,sep=sep,na="NA")

