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

ADD  --link --keep-git-dir=true https://github.com/ptt/pttbbs.git#master /usr/local/src/pttbbs
COPY --link pttbbs.conf /usr/local/src/pttbbs/
RUN set -eux; \
    mkdir /home/bbs; \
    export BBSHOME=/home/bbs; \
    pmake all install -C /usr/local/src/pttbbs; \
    pmake all install -C /usr/local/src/pttbbs/daemon/logind; \
    pmake     install -C /usr/local/src/pttbbs/sample; \
    ln -sr /home/bbs/bin/bbsrf /home/bbs/bin/utf8; \
    ln -sr /bindports.conf /home/bbs/etc/bindports.conf; \
    rm -rf /usr/local/src/pttbbs;

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
COPY --link --from=build /home/bbs /usr/local/pttbbs
RUN set -eux; \
    groupadd --non-unique --gid 99 bbs; \
    useradd  --non-unique --gid 99 --uid 9999 \
             --home-dir /home/bbs --skel /nonexistence --create-home \
             --shell /usr/sbin/nologin bbs; \
    rm -f /etc/group- /etc/passwd- /etc/.pwd.lock;

COPY --link --chmod=755 entrypoint.sh /
COPY --link crontab bindports.conf /

VOLUME /home/bbs

EXPOSE 23
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/pttbbs/bin/logind", "-D"]
