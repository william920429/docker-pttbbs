ARG DEBIAN_VERSION="latest"

# Build PttBBS
FROM openresty/openresty:${DEBIAN_VERSION} AS pttbbs
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
    mv /home/src/daemon/wsproxy /home/bbs/wsproxy; \
    rm -rf /home/src;
COPY bindports.conf /home/bbs/etc/bindports.conf

# Main Image
FROM openresty/openresty:${DEBIAN_VERSION}
RUN set -eux; \
    . /etc/os-release; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        "libevent-2.1-7$(if [ $VERSION_ID -ge 13 ];then echo t64;fi)" \
        supervisor \
        curl \
        wget \
    ; \
    rm -rf /var/lib/apt/lists/*;

# Install supercronic
# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.41/supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=f70ad28d0d739a96dc9e2087ae370c257e79b8d7 \
    SUPERCRONIC=supercronic-linux-amd64

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

# Install PttChrome
COPY ./PttChrome/. /usr/local/openresty/nginx/html/
RUN set -eux; \
    cd /usr/local/openresty/nginx/html; \
    JSNAME="$(basename ./assets/pttchrome.*.js)"; \
    sed 's@PttChrome@${PTTCHROME_PAGE_TITLE}@' \
        < ./index.html \
        > ./index.html.template; \
    sed 's@wsstelnet://ws.ptt.cc/bbs@${PTTCHROME_SITE}@' \
        < ./assets/${JSNAME} \
        > ./assets/${JSNAME}.template; \
    : > ./index.html; \
    : > ./assets/${JSNAME}; \
    : > /usr/local/openresty/nginx/conf/nginx.conf;

# Install PttBBS
COPY --from=pttbbs /home/bbs /home/pttbbs
RUN set -eux; \
    groupadd --gid 99 bbs; \
    useradd -m -g bbs -s /bin/bash -u 9999 -k /nonexistence bbs;

COPY --chmod=755 entrypoint.sh /
COPY supervisord.conf crontab /
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf.template

ENV PTTCHROME_PAGE_TITLE="PttChrome"
ENV PTTCHROME_SITE="wstelnet://127.0.0.1:3000/ws"
ENV PTTCHROME_ORIGIN="http://127.0.0.1:3000"

STOPSIGNAL SIGTERM
EXPOSE 3000
VOLUME /home/bbs

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]
