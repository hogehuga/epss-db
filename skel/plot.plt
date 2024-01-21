set xdata time
set timefmt "%Y-%m-%d"
set format x "%m/%d"
set yrange [0.0:1.0]
set title "EPSS: CVEID"
#period
set terminal png
set output "/opt/epss-db/share/EPSS-CVEID.png"
plot "/opt/epss-db/share/FILENAME" using 1:2 with lines title "EPSS", "/opt/epss-db/share/FILENAME" using 1:3 with lines title "Percentile"
