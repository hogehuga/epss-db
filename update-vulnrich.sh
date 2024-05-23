#!/bin/sh

# env
targetdir="/opt/epss-db/vulnrichment"
outfile="/var/lib/mysql-files/vulnrichment.csv"
# file pre delete
echo "rmfile"
if [ -e $outfile ]; then
  rm $outfile
  echo "rm"
fi

# update vulnrichment
echo "---"
echo "Update Vulnrichment reposiotry."
cd $targetdir
git pull

# create CSV data from Vulnrichment JSON
echo "---"
echo "Create import csv file."
find $targetdir -name "*.json" -exec /opt/epss-db/subprogram/vulnrichUpdate.sh {} \;

# import CSV data
echo "---"
echo "Import data to mysql"
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "load data infile '$outfile' into table richment fields terminated by ',' enclosed by '\"' (cveId, adpCweId, adpSSVCExploitation, adpSSVCAutomatable, adpSSVCTechImpact, adpKEVDateadded, adpKEVRef, adp31Score, adp31Severity, adp31Vector, cna31Score, cna31Severity, cna31VectorString, cna40Score, cna40Severity, cna40Vector);"
echo "- finish"
