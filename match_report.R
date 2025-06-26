#!/usr/bin/env Rscript --vanilla

# This script takes a SINGLE COLUMN as CHR:BP in the ph3 1KG data and attaches the RS number
# -nh     no header flag (default: fle has header)
# --help  help function
# 
# NOTE make sure the data are whitesapce delimited.

sink(stderr())

require(readr)

hasheader = T
idtype = 1  # assume the CHR:BP type id. idtype=2: pass both chr and bp columns
idcol = 1   # assume 
idtypestr = c('by CHR:BP','by CHR and BP')

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("attachRS.R is a script to attach 1KG phase 3 RS numbers based on CHR:BP or CHR, BP data.\n")
    cat("  Usage: cat <file> | attachRS.R [-c <id>] (for CHR:BP id type)\n")
    cat("         OR attachRS.R [-c <chr,bp>] (for datasets with only CHR and BP info, recreates the CHR:BP)\n")
    cat("    where id, chr, bp are column numbers to CHR:BP style SNP identifiers\n")
  } else if (args[1] == "-c") {
    colstr = args[2]
    colstrsplit = strsplit(colstr,',')[[1]]
    if (length(colstrsplit)>2) {
      error('Supply max 2 id column (for chr, bp)')
    } 
    idtype = length(colstrsplit);
    idcol = as.numeric(colstrsplit)
  }
}

cat(sprintf("Merging type %d (%s) on column %d\n",idtype,idtypestr[idtype],idcol[1]),file=stderr())
cat('reading data')
# read stdin with whitespace delimiter
data <- read.table(file("stdin"), header=T, sep="")

# read ref data with whitespace
cat('reading reference set\n')
refdata <- read.table("/Volumes/FiveTB/Genetics/RefSets/1000Genomes/Phase3/CHRBP_RS_A1A2.0.01.phase3.gz",
                      header=T)

# check if data ID is already available or should be recreated from CHR:BP
if (idtype==2) {
  # recreate CHR:BP column
  data$tmpchrbp_id = paste(data[,idcol[1]],data[,idcol[2]],sep=":")
  idcol = which(colnames(data)=='tmpchrbp_id')
}
cat('merging data with reference\n')
M = merge(x = data, y = refdata, by.x = colnames(data)[idcol], by.y = 'CHRBP', all.x = TRUE)

cat('writing data\n');
sink(NULL);
write.table(M,file=stdout(),row.names=F,col.names=T,quote=F)







