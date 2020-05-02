FROM debian:buster
LABEL maintainer = Cristian Sandu <cristian.sandu@gmail.com>

ENV SWITCH_VER=v1.10.2

# Install Required Dependencies
RUN apt update \
    && apt upgrade -y \
    && apt install -y \
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
        php-mysql \
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
        postgresql-client \
        unzip \
        netcat

# Setup Freeswitch repo
COPY ./add-freeswitch-repo.sh /usr/src/freeswitch/add-freeswitch-repo.sh
RUN /usr/src/freeswitch/add-freeswitch-repo.sh

# Freeswitch build deps
RUN apt build-dep -y freeswitch

# Get Freeswitch sources
RUN cd /usr/src && wget http://files.freeswitch.org/freeswitch-releases/freeswitch-${SWITCH_VER}.-release.zip && \
    unzip freeswitch-${SWITCH_VER}}.-release.zip && \
    rm -R freeswitch && \
    mv freeswitch-${SWITCH_VER}}.-release freeswitch

RUN cd /usr/src/freeswitch/src/mod/endpoints/mod_gsmopen/gsmlib/gsmlib-1.10-patched-13ubuntu && ./configure && make && make install
RUN cd /usr/src/freeswitch/src/mod/endpoints/mod_gsmopen/libctb-0.16/build && make DEBUG=0 GPIB=0 && make DEBUG=0 GPIB=0 install

# Enable modules
RUN sed -i /usr/src/freeswitch/modules.conf -e s:'#endpoints/mod_gsmopen:endpoints/mod_gsmopen:' && \
    sed -i /usr/src/freeswitch/modules.conf -e s:'#databases/mod_mariadb:databases/mod_mariadb:' && \
    sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_avmd:applications/mod_avmd:' && \
    sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_callcenter:applications/mod_callcenter:' && \
    sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_cidlookup:applications/mod_cidlookup:' && \
    sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_memcache:applications/mod_memcache:' && \
    sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_nibblebill:applications/mod_nibblebill:' && \
    sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_curl:applications/mod_curl:' && \
    sed -i /usr/src/freeswitch/modules.conf -e s:'#formats/mod_shout:formats/mod_shout:' && \
    sed -i /usr/src/freeswitch/modules.conf -e s:'#formats/mod_pgsql:formats/mod_pgsql:'

# Configure build
RUN cd /usr/src/freeswitch && ./configure && ./configure -C --enable-portable-binary --disable-dependency-tracking \
    --prefix=/usr --localstatedir=/var --sysconfdir=/etc \
    --with-openssl --enable-core-pgsql-support

# Build & install
RUN cd /usr/src/freeswitch && \
    make && \
    make install && \
    make sounds-install moh-install && \
    make hd-sounds-install hd-moh-install && \
    make cd-sounds-install cd-moh-install

# Move the music into music/default directory
RUN mkdir -p /usr/share/freeswitch/sounds/music/default && \
    mv /usr/share/freeswitch/sounds/music/*000 /usr/share/freeswitch/sounds/music/default

RUN chown -R www-data:www-data /etc/freeswitch && \
    chown -R www-data:www-data /var/lib/freeswitch && \
    chown -R www-data:www-data /usr/share/freeswitch && \
    chown -R www-data:www-data /var/log/freeswitch && \
    chown -R www-data:www-data /var/run/freeswitch

# Fix event_socket config to listen on localhost
RUN sed -i 's/::/127.0.0.1/g' /usr/local/freeswitch/conf/autoload_configs/event_socket.conf.xml

COPY start-freeswitch.sh /usr/bin/start-freeswitch.sh

# Remember, docker cannot handle too many ports
EXPOSE 5060/udp
EXPOSE 16384-32768/udp

# Persist Freeswitch data
VOLUME ["/usr/local/freeswitch/"]
