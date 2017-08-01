#!/bin/bash

expn=$1
vrnm=$2

FILEROOT="../result"

for seas in "DJF"
do
	cdo sellonlatbox,60,140,10,50 ${FILEROOT}/${expn}.${vrnm}.${seas}.mean.nc tmp.0.nc
	cdo timmean tmp.0.nc tmp.1.nc
	cdo sub tmp.0.nc tmp.1.nc tmp.2.nc
	cdo eof,10 tmp.2.nc ${expn}.${vrnm}.${seas}.eigenvals.nc ${expn}.${vrnm}.${seas}.eofs.nc
	rm tmp.?.nc -f
done

