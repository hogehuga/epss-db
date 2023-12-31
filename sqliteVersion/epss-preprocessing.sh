#!/bin/sh
cd epss-data

# 1st season
cd 1st

for file in *.gz
do
	TODAY=`echo $file | sed -e "s/epss_scores-\([0-9]*-[0-9]*-[0-9]*\)\.csv\.gz/\1/g"`
	OUTFILE=`echo $file|sed -e "s/\(^.*\)\.gz/\1/g"`
	echo "target file: $file"
	gunzip $file
	grep -v "cve.epss" $OUTFILE | sed -e "s/^\(.*\)$/\1,,,$TODAY/g" > ../$OUTFILE
	gzip $OUTFILE
done

cd ..

# 2nd season
cd 2nd
for file in *.gz
do
	TODAY=`echo $file | sed -e "s/epss_scores-\([0-9]*-[0-9]*-[0-9]*\)\.csv\.gz/\1/g"`
	OUTFILE=`echo $file|sed -e "s/\(^.*\)\.gz/\1/g"`
	echo "target file: $file"
	gunzip $file
	grep -v "cve.epss" $OUTFILE | sed -e "s/^\(.*\)$/\1,,$TODAY/g" > ../$OUTFILE
	gzip $OUTFILE
done

cd ..

# 3nd season
cd 3rd
for file in *.gz
do
	TODAY=`echo $file | sed -e "s/epss_scores-\([0-9]*-[0-9]*-[0-9]*\)\.csv\.gz/\1/g"`
	OUTFILE=`echo $file|sed -e "s/\(^.*\)\.gz/\1/g"`
	gunzip $file
	MODEL=`head -n 1 $OUTFILE | grep "#model_version"| sed -e "s/#model_version:\(.*\),score.*/\1/g"`
	echo "target file: $file"
	grep -v "cve.epss" $OUTFILE | grep -v "#model_version"| sed -e "s/^\(.*\)$/\1,$MODEL,$TODAY/g" > ../$OUTFILE
	gzip $OUTFILE
done

cd ../..

