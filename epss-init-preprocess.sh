#!/bin/sh
BASEPATH=/opt/epss-db/epss-data
cd $BASEPATH


# 1st season
if [ -d 1st ]; then
    cd $BASEPATH/1st

    for file in *.gz
    do
        FILEDATE=`echo $file | sed -e "s/epss_scores-\([0-9]*-[0-9]*-[0-9]*\)\.csv\.gz/\1/g"`
        OUTFILE=`echo $file|sed -e "s/\(^.*\)\.gz/\1/g"`
        echo "target file: $file"
        gunzip $file
        #grep -v "cve.epss" $OUTFILE | sed -e "s/^\(.*\)$/\1,,,$FILEDATE/g" > ../$OUTFILE
        grep -v "cve.epss" $OUTFILE | sed -e "s/^\(.*\),\(.*\)$/\"\1\",\2,NULL,NULL,\"$FILEDATE\"/g" > ../$OUTFILE
        gzip $OUTFILE
    done
    cd ..
else
    echo "...1st directory is not exsist."
fi

# 2nd season
## [cve, epss, percentile]
if [ -d 2nd ]; then
    cd $BASEPATH/2nd
    for file in *.gz
    do
        FILEDATE=`echo $file | sed -e "s/epss_scores-\([0-9]*-[0-9]*-[0-9]*\)\.csv\.gz/\1/g"`
        OUTFILE=`echo $file|sed -e "s/\(^.*\)\.gz/\1/g"`
        echo "target file: $file"
        gunzip $file
        #grep -v "cve.epss" $OUTFILE | sed -e "s/^\(.*\)$/\1,,$FILEDATE/g" > ../$OUTFILE
        grep -v "cve.epss" $OUTFILE | sed -e "s/^\(.*\),\(.*,.*\)$/\"\1\",\2,NULL,\"$FILEDATE\"/g" > ../$OUTFILE
        gzip $OUTFILE
    done
    cd ..
else
    echo "...2nd directory is not exsist."
fi

# 3nd season
## [cve, epss, percentile, model_version]
if [ -d 2nd ]; then
    cd $BASEPATH/3rd
    for file in *.gz
    do
        FILEDATE=`echo $file | sed -e "s/epss_scores-\([0-9]*-[0-9]*-[0-9]*\)\.csv\.gz/\1/g"`
        OUTFILE=`echo $file|sed -e "s/\(^.*\)\.gz/\1/g"`
        gunzip $file
        MODEL=`head -n 1 $OUTFILE | grep "#model_version"| sed -e "s/#model_version:\(.*\),score.*/\1/g"`
        echo "target file: $file"
        #grep -v "cve.epss" $OUTFILE | grep -v "#model_version"| sed -e "s/^\(.*\)$/\1,$MODEL,$FILEDATE/g" > ../$OUTFILE
        grep -v "cve.epss" $OUTFILE | grep -v "#model_version" | sed -e "s/^\(.*\),\(.*,.*\)$/\"\1\",\2,\"$MODEL\",\"$FILEDATE\"/g" > ../$OUTFILE
        gzip $OUTFILE
    done
else
  echo "...3rd directory is not exsist."
fi


cd $BASEPATH

