#!/bin/tcsh
source ./code/code.main/custom-tcshrc    # customize shell environment

##
## USAGE: hicseq-virtual4C.tcsh OUTPUT-DIR PARAM-SCRIPT MATRIX-BRANCH OBJECT
##

if ($#argv != 4) then
  grep '^##' $0
  exit
endif

set outdir = $1
set params = $2
set branch = $3
set objects = ($4)

if ($#objects>1) then
  send2err "Error: virtual4C operation is not implemented for multi-object grouping."
  exit 1
endif

set object = $objects[1]

# read variables from input branch
source ./code/code.main/scripts-read-job-vars $branch "$object" "genome genome_dir unit"

# run parameter script
source $params

# create path
scripts-create-path $outdir/

# -------------------------------------
# -----  MAIN CODE BELOW --------------
# -------------------------------------

# determine scaling factor for sequencing depth
set n_reads = `cat $branch/$object/stats.tsv | grep '^ds-accepted-intra	' | cut -f2`
scripts-send2err "- number of reads = $n_reads"

# determine radius around anchors
set radius = `echo $resolution/2 | bc`

# Process each chromosome separately
set CHR = `cat $genome_dir/genome.bed | cut -f1 | grep -wvE "$chrom_excluded"`
set jid =
foreach chr ($CHR)
  mkdir -p $outdir/$chr
  cat $viewpoints_file | gtools-regions center | gtools-regions bed | cut -f-6 | awk -v c=$chr '$1==c' >! $outdir/$chr/vp.bed         # generate chromosome-specific viewpoints file 
  if (`cat $outdir/$chr/vp.bed | wc -l`>0) then 
    echo "Chromosome $chr..." | scripts-send2err
    set jpref = $outdir/__jdata/job.$chr
    set mem = 20G   #`du $branch/$object/matrix.$chr.mtx | awk '{printf "%ld\n", 5+2*$1/100000}' | tools-vectors cutoff -n 0 -u -c 40`G
    scripts-create-path $jpref
    set Rcmd = "Rscript ./code/virtual4C.r --nreads=$n_reads --unit=$unit --vp-file=$outdir/$chr/vp.bed --maxdist=$maxdist --radius=$radius $outdir/$chr $chr $branch/$object/matrix.$chr.mtx"
    echo $Rcmd | scripts-send2err
    set jid = ($jid `scripts-qsub-run $jpref 1 $mem $Rcmd`)
  endif
end

# wait until all jobs are completed
scripts-send2err "Waiting until all jobs are completed..."
scripts-qsub-wait "$jid"

# organize virtual 4Cs into a single directory
scripts-send2err "Organizing virtual 4Cs into a single directory..."
foreach chr ($CHR)
  if (`cat $outdir/$chr/vp.bed | wc -l`>0) then 
    mv $outdir/$chr/*.bedgraph $outdir
  endif
  gzip $outdir/*.bedgraph
  rm -rf $outdir/$chr
end

# -------------------------------------
# -----  MAIN CODE ABOVE --------------
# -------------------------------------

# save variables
source ./code/code.main/scripts-save-job-vars

# done
scripts-send2err "Done."


