#!/usr/bin/env Rscript --vanilla

sink(stderr())

# Merge dataset in file1 file2 on 

files=c("","")
col = c(1,1)
hasheader = T
mergetype='i'

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[1]=="--help") {
    cat("corr.R is a script to calculate the correlation between columns of numbers.\n")
    cat("  Usage: cat <file> | corr.R [-h]\n")
    stop()
  } 
  v=1
  fc=1
  while (v<=length(args)) {
    if (args[v] == "-1") {
      col[1] = as.numeric(args[v+1])
      v = v + 2
    } else if (args[v] == "-2") {
      col[2] = as.numeric(args[v+1])
      v = v + 2
    } else if (args[v] == "-h") {
      if (args[v+1] %in% c('on','1','T','true','TRUE')) {
        hasheader = T
      } else {
        hasheader = F
      }
      v = v + 2
    } else if (args[v]=='--left') {
      mergetype = 'l'
      v = v + 1
    } else if (args[v]=='--right') {
      mergetype = 'r'
      v = v + 1
    } else if (args[v]=='--inner') {
      mergetype = 'i'
      v = v + 1
    } else if (args[v]=='--outer') {
      mergetype = 'o'
      v = v + 1
    } else if (!(substr(args[v],1,1)=='-')) {
      files[fc] = args[v]
      fc = fc + 1
      v = v + 1
    }
  }
}


if (fc != 3) {
  stop('Must supply two files')
}

data = list()
for (fc in (1:2)) {
  cat(sprintf('Reading file %s',files[fc]))
  data[[fc]] <- read.table(files[fc], header=hasheader, sep="", quote="")
  cat('\n')
}

if (mergetype=='l') {
  BY=c(T,F)
} else if (mergetype=='r') {
  BY=c(F,T);
} else if (mergetype=='i') {
  BY=c(F,T);
} else if (mergetype=='o') {
  BY=c(T,T);
}
cat('merging\n')
M = merge(data[[1]],data[[2]],
          by.x=colnames(data[[1]])[col[1]], by.y=colnames(data[[1]])[col[1]],
          all.x=BY[1], all.y=BY[2])

sink(NULL)
write.table(M, file=stdout(), row.names=F, col.names=hasheader, quote=F)

