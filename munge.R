#!/usr/bin/env Rscript --vanilla

# this script runs the munge script on the input file passed

sink('/dev/null')
require(GenomicSEM)
Sys.sleep(.1)
sink()

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if ((length(args)==1 && args[[1]]=="--help") || length(args)==0) {
  cat("munge.R is a script to munge sumstats data and output under <name>\n")
  cat("  Usage: munge.R <sumstats file> <name> --no-hm3 --no-mhc --hm3dir --col-names SNP=<snpcol>,MAF=<MAF col>...\n")
  cat("  First links the w_hm3.snplist file to reduce the SNPs to HM3\n")
  cat("  Next performs the munge using standard parameters.\n")
  cat("  --no-hm3 does not merge with w_hm3.snplist but a 'full' snplist from HRC with MAF>0.005\n")
  cat("  --no-mhc merges with w_hm3_NoMHC.snplist (no MHC SNPs)\n")
  cat("  -N <number>\n")
  cat("  --column-names [SNP=<snp_col_name>],[CHR=<chr_col_name>] ...\n")
  cat("  --maf-filter <double>\n")
  cat("      passes to maf.filter. If MAF column not found this produces a warning, not an error. def=0.01\n\n")
  stop("No input found")
}

### default settings
default.col = c("SNP", "A1", "A2", "effect", "INFO", "P", "N", "MAF", "Z")
maf.filter = 0.01
for (i in 1:length(default.col)) {
  eval(parse(text=sprintf('col%s="%s"',default.col[i],default.col[i])))
}
N = NULL
cHM3 = '~/bin/ldsc/w_hm3.snplist'

### Check first if number of parameters WITHOUT '-' equals two. These
### are the filename and the output prefix and MUST be present
v = 1
nonparcount=0
while (v <= length(args)) {

  if (substr(args[[v]],1,1) != '-') {
    nonparcount=nonparcount+1
    if (nonparcount==1) {
      fn = args[[v]]
    } else if (nonparcount==2) {
      name = args[[v]]
    } else {
      error('Too many input parameters! Pass input file name and output prefix.')
    }

  ### parse the command line '-' parameters here
  } else if (args[[v]]=='--no-hm3') {
    cHM3 = '~/bin/ldsc/w_HRC.snplist'

  ### no-mhc (default is to include MHC)
  } else if (args[[v]]=='--no-mhc') {
    cHM3 = '~/bin/ldsc/w_hm3_NoMHC.snplist'

  ### column-names: Parse column names
  } else if (args[[v]] %in% c('--column-names','--col-names','--colnames')) {
    recode.col.names=args[[v+1]]
    print(recode.col.names)
    print(strsplit(recode.col.names,",")[[1]])
    for (s in strsplit(recode.col.names,",")[[1]]) {
      c = strsplit(s,"=")[[1]]
      eval(parse(text=sprintf('col%s="%s"',c[1],c[2])))
      cat(sprintf('executed %s\n',sprintf('col%s="%s"',c[1],c[2])))
    }
    v=v+1

  ### MAF for filtering
  } else if (args[[v]] %in% c('--maf','--maf-filter')) {
    maf.filter = as.numeric(args[v+1])
    v=v+1

  ### Predefined N
  } else if (args[[v]]=='-N') {
    N=as.numeric(args[[v+1]])
    v=v+1

  } else {
    stop ('Error: unknown parameter')
  }

  v=v+1
}
### stop if the name and
if (nonparcount<2) {
  stop('Missing input parameters! Pass input file name and output prefix alongside "-" parameters.')
}

# link the right snplist file
cat(sprintf('matching to snplist %s\n',cHM3))
system("rm snplistxxx")
system(sprintf("ln -s %s snplistxxx",cHM3))

# get the column identifiers
str=c()
for (i in 1:length(default.col)) {
  str = c(str, sprintf('%s=%s',default.col[i],eval(parse(text=sprintf("col%s",default.col[i])))))
}
cat('These are the column names:\n')
print(str)

# do the munge
if (!is.null(N)) {
  GenomicSEM::munge(
    files=c(fn), hm3='snplistxxx',
    trait.names=c(name),
    N=N,
    column.names=str,
    maf.filter=maf.filter
  )
} else {
  GenomicSEM::munge(
    files=c(fn), hm3='snplistxxx',
    trait.names=c(name),
    column.names=str,
    maf.filter=maf.filter
  )
}
