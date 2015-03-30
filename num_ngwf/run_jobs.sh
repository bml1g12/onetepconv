#!/bin/bash


touch current_status

for dir in */; 
do
 echo "Now running in $dir" >> current_status
 cd ./$dir
 rootname=`echo *.dat | sed -r "s/\.dat\$//"`
 echo $rootname
 /local/scratch/bml1g12/ONETEP_3.5.9.8/devel/bin/onetep.RH6.intel $rootname.dat > $rootname.onetep 2> $rootname.err 
 cd ..
done
