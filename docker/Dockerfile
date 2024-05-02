FROM mysql:latest

RUN microdnf install git wget vim gnuplot jq
RUN sed -i "s/^\(secure-file-priv\=\).*/\1\/opt\/epss-db\/epss-data/g" /etc/my.cnf
RUN cd /opt && git clone https://github.com/hogehuga/epss-db
RUN cp /opt/epss-db/docker/env/.bashrc /root
RUN mkdir /opt/epss-db/share
