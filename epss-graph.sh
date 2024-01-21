#!/bin/sh

CVEID=""
ALLPERIODS=false
TEMPLATE=/opt/epss-db/skel/plot.plt

# parsing argument
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -cve) CVEID="$2"; shift ;;
	-a) ALLPERIODS=true ;;
    esac
    shift
done

if [ -z "$CVEID" ]; then
    echo "Usage: $0 -cve CVE-ID [-a]"
    exit 1
fi

if ! [[ $CVEID =~ ^CVE-[0-9]{4}-[0-9]+$ ]]; then
    echo "Invalid CVE-ID format"
    exit 1
fi

OUTFILECSV="/opt/epss-db/share/$CVEID.csv"
PLOTFILE="/opt/epss-db/share/skel-$CVEID.plt"
# csv output

/usr/bin/mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb --batch --raw -e "select date,epss,percentile from epssdb where cve=\"$CVEID"\" | sed -e "s/\t/\ /g" | sed -e "s/date/#date/g" > $OUTFILECSV
LINES=`wc -l $OUTFILECSV | sed -e "s/\ .*//g"`
if [ $LINES -eq 0 ]; then
    echo "CVE-ID is not exists."
    rm $OUTFILECSV
    exit 1
fi

# plot
## create plot file

cp $TEMPLATE $PLOTFILE
sed -i -e "s/CVEID/$CVEID/g" $PLOTFILE
sed -i -e "s/FILENAME/$CVEID\.csv/g" $PLOTFILE

## #period
if [ "$ALLPERIODS" = false ]; then
    STARTDATE=`date --date "180 days ago" '+%Y-%m-%d'`
    sed -i -e "s/^#period$/set\ xrange\ \[\"$STARTDATE\":]/g" $PLOTFILE
fi

## plot
LANG=C.utf8 gnuplot $PLOTFILE

rm $PLOTFILE
