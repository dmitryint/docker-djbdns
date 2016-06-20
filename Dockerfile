FROM debian

RUN buildDeps=' \
    gcc \
    curl \
    ca-certificates \
	' \
set -x \
&& echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup \
&& echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache \
&& apt-get update \
&& apt-get install -y $buildDeps \
    ucspi-tcp \
    daemontools \
    make \
&& cd /usr/src \
&& curl https://cr.yp.to/djbdns/djbdns-1.05.tar.gz -o djbdns-1.05.tar.gz \
&& tar -xf djbdns-1.05.tar.gz \
&& cd djbdns-1.05 \
&& echo gcc -O2 -include /usr/include/errno.h > conf-cc \
&& make \
&& make setup check \
&& cd / \
&& rm -rf /usr/src/* \
&& apt-get -y purge --auto-remove $buildDeps \
&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN dnscache-conf nobody nobody /dnscache
RUN echo 0.0.0.0 >/dnscache/env/IP
RUN tinydns-conf nobody nobody /tinydns 0.0.0.0

EXPOSE 53 53/udp
