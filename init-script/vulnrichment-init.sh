#!/bin/bash

cd /opt/epss-db
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root -e "set global local_infile = 1;"
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "create table richment( id int auto_increment, cveId varchar(30), adpCweId varchar(40), adpSSVCExploitation varchar(6), adpSSVCAutomatable varchar(3), adpSSVCTechImpact varchar(7), adpKEVDateadded date, adpKEVRef varchar(2048), adp31Score int, adp31Severity varchar(8), adp31Vector varchar(130), cna31Score int, cna31Severity varchar(8), cna31VectorString varchar(130), cna40Score int, cna40Severity varchar(8), cna40Vector varchar(130), INDEX (id));"
