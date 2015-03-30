#!/bin/bash

#todo: Insert Error Checking to ensure that the integer/flaot types entered by user are correct.
#todo: Insert handling of the case whereby there are unspecified parameters

awk {'print $1" "$2'} ./input/settings.conv > ./input/input.tmp #removes comments from input file 
clean="T" #default is to delete all input files from previous runs
clean=`grep -i 'clean' ./input/input.tmp | awk {'print $2'}` #T/F 
min_cutoff=`grep -i 'min_cutoff' ./input/input.tmp | awk {'print $2'}` #float/integer
cutoff_spacing=`grep -i 'cutoff_spacing' ./input/input.tmp | awk {'print $2'}` #float/integer
cutoff_number_of_SPE=`grep -i 'cutoff_number_of_SPE' ./input/input.tmp | awk {'print $2'}` #integer
interval1=`echo "$cutoff_spacing * $cutoff_number_of_SPE" | bc`
max_cutoff=`echo "$interval1 + $min_cutoff" | bc`

reuse_calculations=`grep -i 'reuse_calculations' ./input/input.tmp | awk {'print $2'}` #T/F 

min_NGWF_radius=`grep -i 'min_NGWF_radius' ./input/input.tmp | awk {'print $2'}` #float/integer
NGWF_radius_spacing=`grep -i 'NGWF_radius_spacing' ./input/input.tmp | awk {'print $2'}` #float/integer
NGWF_radius_number_of_SPE=`grep -i 'NGWF_radius_number_of_SPE' ./input/input.tmp | awk {'print $2'}` #integer

##calculated parameters
interval2=`echo "$NGWF_radius_spacing * $NGWF_radius_number_of_SPE" | bc`
max_NGWF_radius=`echo "$interval2 + $min_NGWF_radius" | bc`
##end calculated parameters

increased_ngwfs=6 #number of ngwfs increased by x from the value initalised in /input.dat
increased_ngwfs=`grep -i 'increased_ngwfs' ./input/input.tmp | awk {'print $2'}` #integer

per_element=T #will only vary species block parameters on a per element basis
per_element=`grep -i 'per_element' ./input/input.tmp | awk {'print $2'}` #T/F 

rm ./input/input.tmp



