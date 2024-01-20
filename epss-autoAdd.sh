#!/bin/sh

LASTDATE=`/usr/bin/mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -ss -e "select date from epssdb group by date order by date desc limit 1;"`
START_DATE=$(date -d "$LASTDATE +1 day" +"%Y-%m-%d")

#END_DATE=$(date -d "yesterday" +"%Y-%m-%d")
END_DATE=$(date +"%Y-%m-%d")

CURRENT_DATE="$START_DATE"

echo "auto data import"
echo "- from: $START_DATE"
echo "- to  : $END_DATE"
read -p "Hit enter or Cancel(CTRL+C)"


while [[ "$CURRENT_DATE" < "$END_DATE" ]]; do
        echo "  ADD: $CURRENT_DATE"
        /opt/epss-db/epss-add.sh -d $CURRENT_DATE
        CURRENT_DATE=$(date -d "$CURRENT_DATE + 1 day" +"%Y-%m-%d")
done
echo "auto data import finished."
