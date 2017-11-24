#!/bin/tcsh

source ./inputs/params/params.tcsh
module unload r
module load r/3.3.2

set filter_centrotelo = true
set bscore_params = prep_none
set flank_boundaries = 20000
set optimal = <optimal>
set n_categories = 5          # number of boundary categories
set n_boundaries = <n>        # number of boundaries per category (0 = auto)



