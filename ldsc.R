#!/usr/bin/env Rscript --vanilla

# this script runs ld score resgression on the input file passed
null_connection <- file("/dev/null", "w")  # Use "NUL" instead of "/dev/null" on Windows

# Redirect both standard output and messages to /dev/null
sink(null_connection)                       # Redirect standard output
sink(null_connection, type = "message") 

require(GenomicSEM)

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)>0) {
  if (args[[1]]=="--help") {
    sink()
    cat("ldsc.R is a script to run ld score regerssion using GenomicSEM and displays the output.\n")
    cat("  Usage: ldsc.R [-s] <sumstats file> [optional second sumstats logfile] >\n")
    cat("         -s: simply output rG only\n")
    return()
  } 
} else {
  sink()
  error('Must specify name of sumstats file')
}

allargs = args
simple=F
if (args[[1]] == "-s") {
  simple=T
  # remove first item from argument list
  allargs=args[2:length(args)]
}

# allargs now holds one or two items (when correctly called)
fn1 = allargs[[1]]
len=nchar(fn1);
  
if (substr(fn1,len-8,len)=='.sumstats') {
  fn1 = sprintf('%s.gz',fn1)
} else if (substr(fn1,len-2,len)!='.gz') {
  fn1 = sprintf('%s.sumstats.gz', fn1)
}

# compare two traits? If so, args[2] will be defined., Otherwise
# copy fn1 into fn2 as ldsc needs two traits (rG will be 1)
if (length(allargs)==1) {
  fn2 = fn1
} else {
  fn2 = allargs[[2]]
  len=nchar(fn2);
  if (substr(fn2,len-8,len)=='.sumstats') {
    fn2 = sprintf('%s.gz',fn2)
  } else if (substr(fn2,len-2,len)!='.gz') {
    fn2 = sprintf('%s.sumstats.gz', fn2)
  }
}

# create symbolic link to ldsc annotation folder
system("rm -f eurxxx")
system("ln -s ~/bin/ldsc/eur_w_ld_chr/ eurxxx")

# run ldsc with GenomicSEM package
ldsc_output = GenomicSEM::ldsc(
    traits=c(fn1,fn2), 
    sample.prev=c(NA,NA), 
    population.prev=c(NA,NA), 
    ld='eurxxx/', 
    wld='eurxxx/',
    trait.names=c('trait1','trait2'),
    stand=T,
    ldsc.log="ldsc.rg.log"
  )
system('rm eurxxx')

sink()
if (!simple) { cat(sprintf('comparing %s %s\n',fn1,fn2)) }
x = ldsc_output;
if (simple) {
  x$S_Stand[2,1]
  cat(sprintf('%.5f\n',x$S_Stand[2,1])) 
} else if (fn1==fn2) {
  cat(sprintf('h2=%.5f (%.5f) intercept=%.5f rg=%.5f (%.5f)\n',x$S[1,1],sqrt(x$V[1,1]),x$I[1,1],x$S_Stand[2,1],sqrt(x$V_Stand[2,2])))
} else {
  cat(sprintf('h2_1=%.5f (%.5f) intercept_1=%.5f h2_2=%.5f (%.5f) intercept_2=%.5f rg=%.5f (%.5f) rg_intercept=%.5f\n',x$S[1,1],sqrt(x$V[1,1]),x$I[1,1],x$S[2,2],sqrt(x$V[3,3]),x$I[2,2],cov2cor(x$S)[2,1],sqrt(x$V_Stand[2,2]),x$I[2,1]))
}
