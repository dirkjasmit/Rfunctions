#!/usr/local/bin/Rscript --vanilla

sink(stderr())

# Merge datasets in file1 file2 on CHR BP REF ALT and reversed join as well
# columns that must be indicated 
# [CHR BP REF ALT].

files=c("","")

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)==0 || args[1]=="--help") {
  cat("join_genetic.R is a script to join two files based on CHR BP and REF ALT (Note: A2 A1)\n")
  cat("  Usage: join_genetic <file1=col1,col2,col3,col4> <file2=col1,col2,col3,col4>\n")
  cat("  Files may be zipped or not.\n")
  cat("  Files must have a header with column names.\n")
  cat("  The join does not adjust the FREQ, BETA/Z values.\n")
  cat(" \n")
  cat("  Writes to stdout\n")
  stop()
}

colstr=c("CHR","BP","REF","ALT")

# parse the filenames for column numbers
cat('parsing arguments: <filename>=<columns>\n')
filename=c()
columns=list()
for (fc in (1:2)) {
  tmp = strsplit(args[fc],"=")[[1]]
  tmp2 = as.numeric(strsplit(tmp[2],",")[[1]])
  if (length(tmp2) != 4) {
    stop()
  }
  cat(sprintf('filename %s ',tmp[1]))
  filename[fc] = tmp[1]
  for (l in 1:4) {
    cat(sprintf(" %s=%d",colstr[l],tmp2[l]))
  }
  columns[[fc]] = tmp2
  cat('\n')
}

data = list()
for (fc in (1:2)) {
  cat(sprintf('Reading file %s',filename[fc]))
  data[[fc]] <- data.table::fread(file=filename[fc], header=T, sep="auto",
                                  quote="", stringsAsFactors=F)
  cat(sprintf(' %d lines\n',dim(data[[fc]])[1]))
  colnames(data[[fc]])[ columns[[fc]] ] = c("mCHR","mBP","mREF","mALT")
}

cat('merging\n')
M1 = merge(data[[1]],data[[2]], by=c("mCHR","mBP","mREF","mALT"))
# reverse the A1 and A2 in dataset two
colnames(data[[2]])[ columns[[2]] ] = c("mCHR","mBP","mALT","mREF")
M2 = merge(data[[1]],data[[2]], by=c("mCHR","mBP","mREF","mALT"))

# join and sort
cat('append and sort\n')
M = rbind(M1,M2)
M = M[order(M$mCHR,M$mBP),]
colnames(M)[1:4] = colstr

# start output
cat('start output\n')
sink(NULL)
write.table(M, file=stdout(), row.names=F, col.names=T, quote=F)


