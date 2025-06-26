#!/usr/bin/env Rscript --vanilla
  
# This script takes a SINGLE COLUMN as CHR:BP in the ph3 1KG data and attaches the RS number
# -nh     no header flag (default: fle has header)
# --help  help function
# 
# NOTE make sure the data are whitesapce delimited.

sink(stderr())

require(readr)

# assume the CHR:BP type id. idtype=2: pass both chr and bp columns
# idtype=3: CHR:BP AND A1 A2
hasheader = T
idtype = 1
idcol = 1   # assume 
idtypestr = c('by CHR:BP','by CHR and BP')
mergewithA1A2 = F
dosortCHRBP = F
doA1A2 = F
doUKB = F

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("attachRS.R is a script to attach 1KG phase 3 RS numbers based on CHR:BP or CHR, BP data.\n")
    cat("  Usage: cat <file> | attachRS.R [-c <id>] (for CHR:BP id type)\n")
    cat("         OR attachRS.R [-c <chr,bp>] (for datasets with only CHR and BP info, recreates the CHR:BP)\n")
    cat("         OR attachRS.R [-a <a1,a2>] (for merging CHR:BR A1 A2)\n")
    cat("         OR attachRS.R [-u] (for merging CHR:BR:A1:A2 UK biobank Neale SNP identifiers)\n")
    cat("    where id, chr, bp are column numbers to CHR:BP style SNP identifiers\n")
    return(NULL)
  } 
  v=1
  while (v <= length(args)) {
    if (args[v] == "-c") {
      colstr = args[v+1]
      colstrsplit = strsplit(colstr,',')[[1]]
      if (length(colstrsplit)>2) {
        error('Supply max 2 id columns (for -c option)')
      } 
      idtype = length(colstrsplit);
      idcol = as.numeric(colstrsplit)
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
    } else if (args[v] == '-u') {
      doUKB = T
      idtype = 2 # A1 and A2 will be split from the SNP identifier. Remains CHR:BP.
      v=v+1
    } else if (args[v] == '-s') {
      dosortCHRBP = T;
      v=v+1
    } else {
      stop('Unknown parameter')
    }
  }
}

cat(sprintf("Merging type %d (%s) on column %d\n",idtype,idtypestr[idtype],idcol[1]),file=stderr())
if (doUKB) {
  cat("  UKB style merge (CHR:BP:A1:A2)\n",file=stderr())
}
cat('reading data\n')
# read stdin with whitespace delimiter
data <- as.data.frame(data.table::fread('file:///dev/stdin', header=T))
cat(sprintf('data read with %d rows and %d columns\n',dim(data)[1],dim(data)[2]))
#head(data)

# read ref data with whitespace
cat('reading reference set\n')
refdata <- as.data.frame(data.table::fread("/Volumes/FiveTB/Genetics/RefSets/1000Genomes/Phase3/CHRBP_RS_A1A2.0.01.phase3.gz", header=T))
cat(sprintf('refdata read with %d rows and %d columns\n',dim(refdata)[1],dim(refdata)[2]))
colnames(refdata) = c('REF_CHRBP','REF_SNP','REF_A2','REF_A1','REF_FREQ')
#head(refdata)

cat(sprintf("  colname data %s\n",colnames(data)[idcol[1]]),file=stderr())

# UKB data has CHR:BP:A1:A2. Split these into columns, then use idtype 2 matching
if (doUKB) {
  cat('Performing UKB stuff\n',file=stderr())
  cat('  splitting identifier column into CHR BP A1 A2\n',file=stderr())
  tmp = strsplit(as.data.frame(data)[,idcol[1]],split=":")
  cat('  convert to data frame\n',file=stderr())
  tmp = as.data.frame(do.call(rbind, tmp))
  data$CHR = tmp[,1]
  data$BP = tmp[,2]
  data$A1 = tmp[,3]
  data$A2 = tmp[,4]
  head(data)
  cat('  reset id columns to new CHR BP\n',file=stderr())
  idcol[1] = which(colnames(data)=='CHR')
  idcol[2] = which(colnames(data)=='BP')
}

# check if data ID is already available or should be recreated from CHR:BP
if (idtype==2) {
  # recreate CHR:BP column
  cat('creating a CHR:BP column\n')
  data$tmpchrbp_id = paste(data[,idcol[1]],data[,idcol[2]],sep=":")
  idcol = which(colnames(data)=='tmpchrbp_id')
}

if (doA1A2) {
  mergecolstr = colnames(data)[c(idcol,A1A2col)]
  cat(sprintf('merging data with on CHR:BP and A1 A2 (columns %s %s %s)\n',mergecolstr[1],mergecolstr[2],mergecolstr[3]))
  M1 = merge(x = data, y = refdata, 
             by.x = mergecolstr, 
             by.y = c('REF_CHRBP','REF_A1','REF_A2'))
  cat(sprintf('  %d rows match\n',dim(M1)[1]))
  cat(sprintf('merging data with on CHR:BP and A2 A1 (columns %s %s %s)\n',mergecolstr[1],mergecolstr[3],mergecolstr[2]))
  M2 = merge(x = data, y = refdata, 
             by.x = mergecolstr, 
             by.y = c('REF_CHRBP','REF_A2','REF_A1'))
  cat(sprintf('  %d rows match\n',dim(M2)[1]))
  # M2 will have the swapped alleles.
  M2$REF_FREQ = 1-M2$REF_FREQ
  
  M=rbind(M1,M2) # note that this will bind REF_A2 and REF_A1 correctly!
} else {
  cat('merging data with reference\n')
  M = merge(x = data, y = refdata, by.x = colnames(data)[idcol], by.y = 'REF_CHRBP', all.x = TRUE)
}

if (dosortCHRBP) {
  cat('sorting data on CHR BP/POS columns\n')
  # get all column names (BP AND POS). Sort will work even if bot hare present.
  ndx = which(colnames(M) %in% c("CHR","BP","POS"))
  cat('sorting on columns %d and %d\n',ndx[1],ndx[2])
  M = M[order(M[,ndx[1]],M[,ndx[2]]),]
}
cat('writing data\n')
head(M)
sink(NULL)
write.table(M, file=stdout(), row.names=F, col.names=T, quote=F)







