#!/bin/sh

infile=$1
outfile="/var/lib/mysql-files/vulnrichment.csv"

# CVE-ID
cveid=`jq -r '.cveMetadata.cveId // "NULL"' $infile`

# CWE-ID
cweid=`jq -r '.containers.adp[]?.problemTypes[]?.descriptions[]?.cweId' $infile`

# SSVC
ssvcExpl=`jq -r '.containers.adp[]?.metrics[]?.other? | select(.type=="ssvc") | .content?.options[0]?.Exploitation ' $infile`
ssvcAuto=`jq -r '.containers.adp[]?.metrics[]?.other? | select(.type=="ssvc") | .content?.options[1]?.Automatable' $infile`
ssvcTech=`jq -r '.containers.adp[]?.metrics[]?.other? | select(.type=="ssvc") | .content?.options[2]?."Technical Impact"' $infile`

# KEV
kevDate=$(jq -r '.containers.adp[]?.metrics[]?.other? | select(.type == "kev") | .content?.dateAdded' "$infile")
if [ -z $kevDate ] ; then
  kevDate="1900-01-01"
fi

kevRef=`jq -r '.containers.adp[]?.metrics[]?.other? | select(.type=="kev") | .content?.reference'  $infile`

# adp.cvssV31
adpV31score=`jq -r '.containers.adp[]?.metrics[]? | select(.cvssV3_1) | .cvssV3_1.baseScore' $infile`
if [ -z $adpV31score ] ; then
  adpV31score="0"
fi

adpV31severity=`jq -r '.containers.adp[]?.metrics[]? | select(.cvssV3_1) | .cvssV3_1.baseSeverity' $infile`
adpV31vector=`jq -r '.containers.adp[]?.metrics[]? | select(.cvssV3_1) | .cvssV3_1.vectorString' $infile`

# cna.cvssV31
cnaV31score=`jq -r '.containers.cna.metrics[]? | select(.cvssV3_1) | .cvssV3_1.baseScore' $infile`
if [ -z $cnaV31score ] ; then
  cnaV31score="0"
fi
cnaV31severity=`jq -r '.containers.cna.metrics[]? | select(.cvssV3_1) | .cvssV3_1.baseSeverity' $infile`
cnaV31vector=`jq -r '.containers.cna.metrics[]? | select(.cvssV3_1) | .cvssV3_1.vectorString' $infile`

# cna.cvssV40
cnaV40score=`jq -r '.containers.cna.metrics[]? | select(.cvssV4_0) | .cvssV4_0.baseScore' $infile`
if [ -z $cnaV40score ] ; then
  cnaV40score="0"
fi

cnaV40severity=`jq -r '.containers.cna.metrics[]? | select(.cvssV4_0) | .cvssV4_0.baseSeverity' $infile`
cnaV40vector=`jq -r '.containers.cna.metrics[]? | select(.cvssV4_0) | .cvssV4_0.vectorString' $infile`

# output
echo "\"$cveid\",\"$cweid\",\"$ssvcExpl\",\"$ssvcAuto\",\"$ssvcTech\",\"$kevDate\",\"$kevRef\",\"$adpV31score\",\"$adpV31severity\",\"$adpV31vector\",\"$cnaV31score\",\"$cnaV31severity\",\"$cnaV31vector\",\"$cnaV40score\",\"$cnaV40severity\",\"$cnaV40vector\"" >> $outfile

