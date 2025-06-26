#!/usr/bin/env Rscript --vanilla
  
# This script takes a SINGLE COLUMN as CHR:BP in the ph3 1KG data and attaches the RS number
# -nh     no header flag (default: fle has header)
# --help  help function
# 
# NOTE make sure the data are whitesapce delimited.

crit = 2
title = ""
file = 'FigQQ.png'
alpha = .5
sigline = -log10(5E-8)
chrmatch  = ""
bpmatch   = ""
pvalmatch = ""
scheme = 'standard' # possible schemes standard, ukraine, bw
markindep = F
lim = NULL

args = commandArgs(trailingOnly=TRUE)
if (length(args)>0) {
  l = 1
  while (l <= length(args)) {
    if (args[l]=="--help") {
      cat("qq.R is a script to plot a standard Q-Q plot from GWAS results\n")
      cat("  Usage: [gzcat / cat] <file> | qq.R [-t <title>]\n")
      cat("   -t string sets plot title\n")
      cat("   -a float (0 to 1) sets transparency (alpha) of markers\n")
      cat("   --pval string sets the column name for chromosome position\n")
      stop()
    } else if (args[l]=='-t') {
      title = args[l+1]
      l = l + 2
    } else if (args[l]=='-a') {
      alpha = as.numeric(args[l+1])
      l = l + 2
    } else if (args[l]=='--pval') {
      pvalmatch = args[l+1]
      l = l + 2
    } else if (args[l]=='--lim') {
      lim = as.double(args[l+1])
      l = l + 2
    } else if (args[l]=='--scheme') {
      scheme = args[l+1]
      l = l + 2
    } else {
      stop('Unknown parameter')
    }
  }
}

title = gsub("_"," ",title)
if (title != "") {
  cat(sprintf("Plot title: %s\n",title))
} else {
  cat('No title specified')
}
  
# read stdin with whitespace delimiter
data <- as.data.frame(data.table::fread('file:///dev/stdin', header=T))
cat(sprintf('data read with %d rows and %d columns\n',dim(data)[1],dim(data)[2]))

# get the columns
if (nchar(pvalmatch)>0) {
  pcol = which(colnames(data) %in% c(pvalmatch))[1]
} else {
  pcol = which(substr(toupper(colnames(data)),1,3) %in% c('PVA','P'))[1]
  if (length(pcol) == 0) {
    cat('Cannot find PVAL* column\n',file=stderr())
    stop()
  }
}
cat(sprintf('P column %d\n',pcol))

png(file, width=4,height=4,units='in',res=300) 

# st = 0
# if (scheme=='standard') {
#   colors = c(rgb(.8,.3,0,alpha,maxColorValue=1),rgb(.2,.2,.2,alpha,maxColorValue=1))
#   bgcolors = c(rgb(.8/2,.3/2,0,alpha,maxColorValue=1),rgb(0,0,0,alpha,maxColorValue=1))
# } else if (scheme=='ukraine') {
#   colors = c(rgb(0,0,.8,alpha,maxColorValue=1),rgb(.8,.8,0,alpha,maxColorValue=1))
#   bgcolors = c(rgb(0,0,.4,alpha,maxColorValue=1),rgb(.4,.4,0,alpha,maxColorValue=1))
# } else if (scheme=='bw') {
#   colors = c(rgb(0,0,0,alpha,maxColorValue=1),rgb(0,0,0,alpha,maxColorValue=1))
#   bgcolors = c(rgb(0,0,0,alpha,maxColorValue=1),rgb(0,0,0,alpha,maxColorValue=1))
# }

source("/Volumes/FiveTBtwo/Documents/Projecten/Rscripts/pQQ_ex.R")

if (!is.null(lim)) {
  pQQ_ex(data[,pcol], lim=c(0,lim), main=title)
} else {
  pQQ_ex(data[,pcol], main=title)
}

dev.off()
system(sprintf('open "%s"',file))









