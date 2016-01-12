FROM debian:latest

RUN apt-get update && apt-get install -y wget curl telnet

RUN wget https://s3.amazonaws.com/influxdb/influxdb_0.9.6.1_amd64.deb \
  && dpkg -i influxdb_0.9.6.1_amd64.deb

RUN wget http://get.influxdb.org/telegraf/telegraf_0.2.4_amd64.deb \
  && dpkg -i telegraf_0.2.4_amd64.deb

RUN wget https://s3.amazonaws.com/get.influxdb.org/chronograf/chronograf_0.4.0_amd64.deb \
  && dpkg -i chronograf_0.4.0_amd64.deb

RUN wget https://s3.amazonaws.com/influxdb/kapacitor_0.2.4-1_amd64.deb \
  && dpkg -i kapacitor_0.2.4-1_amd64.deb

RUN influxd config > /etc/influxdb/influxdb.generated.conf

RUN apt-get update && apt-get install -y supervisor net-tools

# Configure supervisord
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD ./influxdb.conf /etc/influxdb/influxdb.conf
ADD ./telegraf.conf /opt/telegraf/telegraf.conf
ADD ./chronograf.toml /opt/chronograf/config.toml
RUN mkdir /opt/kapacitor/
ADD ./kapacitor.conf /opt/kapacitor/kapacitor.conf
RUN rm *.deb
RUN mkdir -p /data/chronograf && chown -R chronograf:chronograf /data/chronograf && chmod 777 /data/chronograf

VOLUME /data/influx/data
VOLUME /data/influx/meta
VOLUME /data/influx/wal
VOLUME /data/kapacitor
VOLUME /data/chronograf

EXPOSE  80
EXPOSE 8125/udp
EXPOSE 10000
EXPOSE 8083
EXPOSE 8086
EXPOSE 8088

CMD     ["/usr/bin/supervisord"]
