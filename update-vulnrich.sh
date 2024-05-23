#!/bin/sh

# env
targetdir="/opt/epss-db/vulnrichment"
outfile="/opt/epss-db/epss-data/vulnrichment.csv"

# file pre delete
if [ -e $outfile ]; then
  rm $outfile
fi

# update vulnrichment
cd $targetdir
git pull

# create CSV data from Vulnrichment JSON
find $targetdir -name "*.json" -exec /opt/epss-db/subprogram/vulnrichUpdate.sh {} \;

# import CSV data
mysql --defaults-extra-file=/opt/epss-db/my.cnf epssdb -e "load data infile '$outfile' into table richment fields terminated by ',' enclosed by '\"' (cveId, adpCweId, adpSSVCExploitation, adpSSVCAutomatable, adpSSVCTechImpact, adpKEVDateadded, adpKEVRef, adp31Score, adp31Severity, adp31Vector, cna31Score, cna31Severity, cna31VectorString, cna40Score, cna40Severity, cna40Vector);"

# file delete
if [ -e $outfile ]; then
  rm $outfile
fi
