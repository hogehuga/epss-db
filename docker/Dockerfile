FROM mysql:latest

RUN microdnf install git wget vim
RUN sed -i "s/^\(secure-file-priv\=\).*/\1\/opt\/epss-db\/epss-data/g" /etc/my.cnf
RUN cd /opt && git clone https://github.com/hogehuga/epss-db
RUN mkdir /opt/epss-db/share
