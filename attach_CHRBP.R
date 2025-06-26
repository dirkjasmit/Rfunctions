#!/usr/bin/env Rscript --vanilla
  
# This script takes a SINGLE COLUMN as SNP in the ph3 1KG data and attaches the CHR and BP 
# --no-header or -n    no header flag (default: fle has header)
# --help  help function
# 
# NOTE make sure the data are whitesapce delimited.

sink(stderr())

require(readr)

# assume thers numbers in column SNP or indicate column number
hasheader = T
mergewithA1A2 = F
dosortCHRBP = F
idcol = 1

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("attach_CHRBP.R is a script to attach 1KG phase 3 RS numbers based on CHR:BP or CHR, BP data.\n")
    cat("  Usage: cat <file> | attach_CHRBP.R [-c <id>] [-a <col1>,<col2>] [-n]\n")
    cat("    -c gives column number for SNP is\n")
    cat("    -a gives column numbers for A1 and A2 columns for extended matching\n")
    cat("    -n indicates no header, otherwise header is assumed and column names lead identification of columns (SNP)\n")
    return(NULL)
  } 
  v=1
  while (v <= length(args)) {
    if (args[v] == "-c") {
      colstr = args[v+1]
      idcol = as.numeric(colstr)
      v=v+2
    } else if (args[v] == '-a') {
      colstr = args[v+1]
      colstrsplit = strsplit(colstr,',')[[1]]
      if (length(colstrsplit)!=2) {
        error('Supply 2 columns with allele info (for -a option)')
      } 
      A1A2col = as.numeric(colstrsplit)
      doA1A2 = T;
      v=v+2
    } else if (args[v] == '-s') {
      dosortCHRBP = T;
      v=v+1
    } else if (args[v] == '-n') {
      hasheader = F;
      v=v+1
    } else {
      stop('Unknown parameter')
    }
  }
}

cat('reading data\n')
# read stdin with whitespace delimiter
data <- as.data.frame(data.table::fread('file:///dev/stdin', header=hasheader))
cat(sprintf('data read with %d rows and %d columns\n',dim(data)[1],dim(data)[2]))
#head(data)

if (hasheader) {
  idcol = which(colnames(data) %in% c('SNP'))
}

# read ref data with whitespace
cat('reading reference set\n')
refdata <- as.data.frame(data.table::fread("/Volumes/FiveTB/Genetics/RefSets/1000Genomes/Phase3/CHRBP_RS_A1A2.0.01.phase3.gz", header=T))
cat(sprintf('refdata read with %d rows and %d columns\n',dim(refdata)[1],dim(refdata)[2]))
colnames(refdata) = c('REF_CHRBP','REF_SNP','REF_A2','REF_A1','REF_FREQ')
#head(refdata)

idcolstr = colnames(data)[idcol]
cat(sprintf("  colname data %s\n", idcolstr),file=stderr())

# UKB data has CHR:BP:A1:A2. Split these into columns, then use idtype 2 matching


cat('merging data with on SNP\n')
orignames = colnames(data)
M = merge(x=data, y=refdata, by.x=idcolstr, by.y='REF_SNP', all.x = TRUE)

cat('writing data\n')
head(M)
tmp = read.table(textConnection(M$REF_CHRBP),sep=':')
M$CHR = tmp[,1]
M$BP = tmp[,2]
M=M[,c(orignames,"CHR","BP")]
sink(NULL)
write.table(M, file=stdout(), row.names=F, col.names=T, quote=F)







