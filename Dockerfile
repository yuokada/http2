#
# This Dockerfile builds a recent curl with HTTP/2 client support, using
# a recent nghttp2 build.
#
# See the Makefile for how to tag it. If Docker and that image is found, the
# Go tests use this curl binary for integration tests.
#

FROM ubuntu:trusty

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git-core build-essential wget

RUN apt-get install -y --no-install-recommends \
       autotools-dev libtool pkg-config zlib1g-dev \
       libcunit1-dev libssl-dev libxml2-dev libevent-dev \
       automake autoconf

# Note: setting NGHTTP2_VER before the git clone, so an old git clone isn't cached:
ENV NGHTTP2_VER v1.9.2
RUN cd /root && git clone https://github.com/tatsuhiro-t/nghttp2.git
WORKDIR /root/nghttp2
RUN git checkout -b ${NGHTTP2_VER} refs/tags/${NGHTTP2_VER} && \
    autoreconf -i && \
    automake && \
    autoconf && \
    ./configure && \
    make && \
    make install

WORKDIR /root
ENV CURL_VER 7.49.0-20160417
RUN wget --quiet http://curl.haxx.se/snapshots/curl-${CURL_VER}.tar.gz && \
    tar -zxf curl-${CURL_VER}.tar.gz
RUN    cd /root/curl-${CURL_VER} && \
    ./configure --with-ssl --with-nghttp2=/usr/local && \
    make && \
    make install && \
    ldconfig

CMD ["-h"]
ENTRYPOINT ["/usr/local/bin/curl"]

