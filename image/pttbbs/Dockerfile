ARG DEBIAN_VERSION="bookworm"
ARG SUPERCRONIC_VERSION="0.2.42"
ARG TARGETARCH

# Build PttBBS
FROM debian:${DEBIAN_VERSION}-slim AS build
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        bmake \
        gcc \
        g++ \
        python3  \
        python-is-python3 \
        libevent-dev \
        pkg-config \
        git \
    ; \
    rm -rf /var/lib/apt/lists/*;

ADD --keep-git-dir=true https://github.com/ptt/pttbbs.git#master /home/src
COPY pttbbs.conf /home/src/
RUN set -eux; \
    mkdir /home/bbs; \
    export BBSHOME=/home/bbs; \
    pmake all install -C /home/src; \
    pmake all install -C /home/src/daemon/logind; \
    pmake     install -C /home/src/sample; \
    ln -sr /home/bbs/bin/bbsrf /home/bbs/bin/utf8
    rm -rf /home/src;
COPY bindports.conf /home/bbs/etc/bindports.conf

# Main Image
FROM debian:${DEBIAN_VERSION}-slim
RUN set -eux; \
    . /etc/os-release; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        "libevent-2.1-7$(if [ $VERSION_ID -ge 13 ];then echo t64;fi)" \
    ; \
    rm -rf /var/lib/apt/lists/*;

# Install supercronic
# Latest releases available at https://github.com/aptible/supercronic/releases
ARG SUPERCRONIC_VERSION
ARG TARGETARCH
ADD --chmod=755 \
    https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH} \
    /usr/local/bin/supercronic

# Install PttBBS
COPY --from=build /home/bbs /usr/local/pttbbs
RUN set -eux; \
    groupadd --gid 99 bbs; \
    useradd -m -g bbs -u 9999 -d /home/bbs -s /usr/sbin/nologin -k /nonexistence bbs;

COPY --chmod=755 entrypoint.sh /
COPY crontab /

STOPSIGNAL SIGTERM
EXPOSE 23
VOLUME /home/bbs

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/pttbbs/bin/logind", "-D"]
