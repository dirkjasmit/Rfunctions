#!/usr/bin/env Rscript --vanilla
  
# This script takes a SINGLE COLUMN as CHR:BP in the ph3 1KG data and attaches the RS number
# -nh     no header flag (default: fle has header)
# --help  help function
# 
# NOTE make sure the data are whitesapce delimited.

crit = 2
title = ""
file = 'FigManhattan.png'
alpha = .5
sigline = -log10(5E-8)
chrmatch  = ""
bpmatch   = ""
pvalmatch = ""
scheme = 'standard' # possible schemes standard, ukraine, bw
markindep = F

args = commandArgs(trailingOnly=TRUE)
if (length(args)>0) {
  l = 1
  while (l <= length(args)) {
    if (args[l]=="--help") {
      cat("manhattan.R is a script to plot a standard Manhatten plot from GWAS results\n")
      cat("  Usage: [gzcat / cat] <sumstats file> | manhattan.R [-c <crit>] [-t <title>] [-a alpha] [--out filename]\n")
      cat("   -c float sets the minimal -log10(p) to plot\n")
      cat("   -t string sets plot title\n")
      cat("   -a float (0 to 1) sets transparency (alpha) of markers\n")
      cat("   -s float (0 to ...) sets a significance line\n")
      cat("   --chr  string sets the column name for chromosome position\n")
      cat("   --bp   string sets the column name for chromosome position\n")
      cat("   --pval string sets the column name for chromosome position\n")
      cat("   --scheme string sets color scheme ([standard],ukraine,bw)\n")
      cat("   --out  string output filename\n")
      stop()
    } else if (args[l]=='-c') {
      crit = as.numeric(args[l+1])
      l = l + 2
    } else if (args[l]=='-t') {
      title = args[l+1]
      l = l + 2
    } else if (args[l]=='-a') {
      alpha = as.numeric(args[l+1])
      l = l + 2
    } else if (args[l]=='-s') {
      sigline = as.numeric(args[l+1])
      l = l + 2
    } else if (args[l]=='--chr') {
      chrmatch = args[l+1]
      l = l + 2
    } else if (args[l]=='--bp') {
      bpmatch = args[l+1]
      l = l + 2
    } else if (args[l]=='--pval') {
      pvalmatch = args[l+1]
      l = l + 2
    } else if (args[l]=='--scheme') {
      scheme = args[l+1]
      l = l + 2
    } else if (args[l]=='--out' || args[l]=='-o') {
      file=args[l+1]
      if (tools::file_ext(file) != "png") {
        file=paste0(file, ".png")
      }
      l = l + 2
    } else if (args[l]=='--mark-peak') {
      markindep = T 
      l = l + 1
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

if (nchar(chrmatch)>0) {
  chrcol = which(colnames(data) %in% c(chrmatch))[1]
} else {
  chrcol = which(toupper(colnames(data)) %in% c('CHR'))[1]
  if (length(chrcol) == 0) {
    cat('Cannot find CHR* column\n',file=stderr())
    stop()
  }
}
cat(sprintf('CHR column %d\n',chrcol))

if (nchar(bpmatch)>0) {
  bpcol = which(colnames(data) %in% c(bpmatch))[1]
} else {
  bpcol = which(substr(toupper(colnames(data)),1,3) %in% c('POS','BP'))[1]
  if (length(bpcol) == 0 || is.na(bpcol)) {
    cat('Cannot find BP column\n',file=stderr())
    stop()
  }
}
cat(sprintf('BP/POS column %d\n',bpcol))

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
#cat('hallo')

png(file, width=10,height=4,units='in',res=300) 

# plot a subset of the data
ndx = as.numeric(data[,pcol])<10^(-crit)
data = data[ndx,]
ylimit = c(crit-.1, 1.1+floor(max(-log10(data[,pcol]))))

st = 0
if (scheme=='standard') {
  colors = c(rgb(.8,.3,0,alpha,maxColorValue=1),rgb(.2,.2,.2,alpha,maxColorValue=1))
  bgcolors = c(rgb(.8/2,.3/2,0,alpha,maxColorValue=1),rgb(0,0,0,alpha,maxColorValue=1))
} else if (scheme=='ukraine') {
  colors = c(rgb(0,0,.8,alpha,maxColorValue=1),rgb(.8,.8,0,alpha,maxColorValue=1))
  bgcolors = c(rgb(0,0,.4,alpha,maxColorValue=1),rgb(.4,.4,0,alpha,maxColorValue=1))
} else if (scheme=='bw') {
  colors = c(rgb(0,0,0,alpha,maxColorValue=1),rgb(0,0,0,alpha,maxColorValue=1))
  bgcolors = c(rgb(0,0,0,alpha,maxColorValue=1),rgb(0,0,0,alpha,maxColorValue=1))
}

midchr = NA
for (chr in 1:22) {
  cat('.')
  ndxchr = as.numeric(data[,chrcol]) == chr
  mn = min(as.numeric(data[ndxchr,bpcol]))
  if (chr == 1) {
    plot(as.numeric(data[ndxchr,bpcol])+st-mn, -log10(data[ndxchr,pcol]), 
         col=colors[(chr %% 2)+1],
         bg=bgcolors[(chr %% 2)+1],
         xaxt='n',
         pch=20,
         ylim=ylimit,
         xlim=c(5E7,2.9E9),
         xlab='',
         cex = .6,
         cex.lab=.7,
         cex.axis = .7,
         ylab='-log10(P)',
         main=title,
         cex.main=.8)
  } else {
    points(as.numeric(data[ndxchr,bpcol])+st-mn, -log10(data[ndxchr,pcol]), 
         col=colors[(chr %% 2)+1],
         bg=bgcolors[(chr %% 2)+1],
         xaxt='n',
         cex = .6,
         pch=20)
  }
  midchr[chr] = st + max(as.numeric(data[ndxchr,bpcol]))/2
  st = st + max(as.numeric(data[ndxchr,bpcol])) - mn + 1E7
    
}
cat('\n')

# add chromosome labels
axis(1,at=midchr,labels=sprintf('chr %d',1:22),las=2,cex.axis=.7)
# add significance line
if (!is.na(sigline)) {
  abline(h=sigline,col=rgb(1,0,0,maxColorValue=1,alpha=.5))
}
dev.off()
 
system(sprintf('open "%s"',file))









