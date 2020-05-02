FROM debian:buster
LABEL maintainer = Cristian Sandu <cristian.sandu@gmail.com>

ENV SWITCH_VER=v1.10

# Install Required Dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        ca-certificates \
        git \
        sed \
        lsb-release \
        ssl-cert \
        ghostscript \
        libtiff5-dev \
        libtiff-tools \
        nginx \
        php \
        php-cli \
        php-fpm \
        php-pgsql \
        php-odbc \
        php-curl \
        php-imap \
        php-xml \
        wget \
        curl \
        openssh-server \
        supervisor \
        net-tools \
        gnupg2 \
        netcat

RUN	wget -O - https://files.freeswitch.org/repo/deb/rpi/debian-release/freeswitch_archive_g0.pub | apt-key add - && \
	echo "deb http://files.freeswitch.org/repo/deb/rpi/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list && \
	echo "deb-src http://files.freeswitch.org/repo/deb/rpi/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list && \
    apt-get update

RUN apt-get build-dep -y freeswitch
RUN cd /usr/src/ && git clone -b ${SWITCH_VER} https://github.com/signalwire/freeswitch    

RUN cd /usr/src/freeswitch/src/mod/endpoints/mod_gsmopen/gsmlib/gsmlib-1.10-patched-13ubuntu && ./configure && make && make install
RUN cd /usr/src/freeswitch/src/mod/endpoints/mod_gsmopen/libctb-0.16/build && make DEBUG=0 GPIB=0 && make DEBUG=0 GPIB=0 install

RUN cd /usr/src/freeswitch && \
    git config pull.rebase true && \
    ./bootstrap.sh -j && \
    sed -i 's/#endpoints\/mod_gsmopen/endpoints\/mod_gsmopen/g' modules.conf && \
    ./configure && make && make install

# Create user 'freeswitch'
# Add it to group 'freeswitch'
# Change owner and group of the freeswitch installation
RUN cd /usr/local && \
    groupadd freeswitch && \
    adduser --quiet --system --home /usr/local/freeswitch --gecos "FreeSWITCH open source softswitch" --ingroup freeswitch freeswitch --disabled-password && \
    chown -R freeswitch:freeswitch /usr/local/freeswitch/ && \
    chmod -R ug=rwX,o= /usr/local/freeswitch/ && \
    chmod -R u=rwx,g=rx /usr/local/freeswitch/bin/*

# Fix event_socket config
RUN sed -i 's/::/127.0.0.1/g' /usr/local/freeswitch/conf/autoload_configs/event_socket.conf.xml

COPY start-freeswitch.sh /usr/bin/start-freeswitch.sh

EXPOSE 5060/udp

# Remember, docker cannot handle too many ports
EXPOSE 16384-32768/udp

VOLUME ["/usr/local/freeswitch/", "/usr/src/freeswitch/"]
