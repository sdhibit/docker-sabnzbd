FROM sdhibit/alpine-runit:3.6
MAINTAINER Steve Hibit <sdhibit@gmail.com>

ARG PAR2_VERSION="0.7.3"
ARG PAR2_URL="https://github.com/Parchive/par2cmdline/archive/v$PAR2_VERSION.tar.gz"
ARG SABYENC_VERSION="3.0.2"

# Install & Build Dependencies
RUN apk --update upgrade \
 && apk add --no-cache --virtual=build-dependencies \
	autoconf \
	automake \
	build-base \
	py-setuptools \
	python-dev \
 && apk --update upgrade \
 && apk add --no-cache \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
	ca-certificates \
	ffmpeg \
	openssl \
	p7zip \
	py-cffi \
	py-cheetah \
	py-configobj \
	py-cryptography \
	py-dbus \
	py-enum34 \
	py-feedparser \
	py-openssl \
	py-pip \
	py-six \
	python \
    unzip \
    unrar \
 && pip install --upgrade \
    sabyenc=="$SABYENC_VERSION" \
 && mkdir -p /tmp/par2 \
 && curl -kL ${PAR2_URL} | tar -xz -C /tmp/par2 --strip-components=1 \
 && cd /tmp/par2 \
 && aclocal \
 && automake --add-missing \
 && autoconf \
 && ./configure \
 && make \
 && make install \
 && apk del --purge build-dependencies \
 && rm -rf /tmp/*

# Set SABnzbd variables
ARG APP_VERSION="2.1.0"
ARG APP_BASEURL="https://github.com/sabnzbd/sabnzbd/releases/download"
ARG APP_PKGNAME="${APP_VERSION}/SABnzbd-${APP_VERSION}-src.tar.gz"
ARG APP_URL="${APP_BASEURL}/${APP_PKGNAME}"
ARG APP_PATH="/opt/sabnzbd"

# Download & Install Sonarr
RUN mkdir -p ${APP_PATH} \
 && curl -kL ${APP_URL} | tar -xz -C ${APP_PATH} --strip-components=1 

# Create user and change ownership
RUN mkdir /config \
 && addgroup -g 666 -S sabnzbd \
 && adduser -u 666 -SHG sabnzbd sabnzbd \
 && chown -R sabnzbd:sabnzbd \
    ${APP_PATH} \
    "/config"

VOLUME ["/config"]

# Default Sabnzbd HTTP server port
EXPOSE 8080

WORKDIR ${APP_PATH}

# Add services to runit
ADD sabnzbd.sh /etc/service/sabnzbd/run
RUN chmod +x /etc/service/*/run
