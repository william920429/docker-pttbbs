ARG NODE_MAJOR=lts
ARG DEBIAN_VERSION=latest

# Build PttChrome
FROM node:${NODE_MAJOR} AS pttchrome
RUN set -eux; \
    cd /usr/src; \
    curl -fsSL -o PttChrome-dev.zip https://github.com/robertabcd/PttChrome/archive/refs/heads/dev.zip; \
    unzip PttChrome-dev.zip; \
    cd PttChrome-dev; \
    yarn upgrade; \
    NODE_ENV=production yarn build; \
    mv ./dist /usr/src/static; \
    cd /usr/src; \
    rm -rf ./PttChrome-dev; \
    yarn cache clean --all;

# Already built PttBBS binary
FROM ghcr.io/bbsdocker/imageptt:${DEBIAN_VERSION} AS pttbbs

# Main Image
FROM openresty/openresty:${DEBIAN_VERSION}
# Install Dependency
RUN set -eux; \
    . /etc/os-release; \
    groupadd --gid 99 bbs; \
    useradd -m -g bbs -s /bin/bash --uid 9999 bbs; \
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
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.39/supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=c98bbf82c5f648aaac8708c182cc83046fe48423 \
    SUPERCRONIC=supercronic-linux-amd64
RUN set -eux; \
    curl -fsSLO "$SUPERCRONIC_URL"; \
    echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c -; \
    chmod +x "$SUPERCRONIC"; \
    mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}"; \
    ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic;

# Install PttChrome
COPY --from=pttchrome /usr/src/static/. /usr/local/openresty/nginx/html/
RUN set -eux; \
    cd /usr/local/openresty/nginx/html; \
    JSNAME="$(basename ./assets/pttchrome.*.js)"; \
    sed 's@PttChrome@${PTTCHROME_PAGE_TITLE}@' \
        ./index.html \
        > ./index.html.template; \
    sed 's@wsstelnet://ws.ptt.cc/bbs@${PTTCHROME_SITE}@' \
        ./assets/${JSNAME} \
        > ./assets/${JSNAME}.template; \
    rm ./index.html \
        ./assets/${JSNAME} \
        /usr/local/openresty/nginx/conf/nginx.conf;

# Install PttBBS
COPY --from=pttbbs /home/bbs /home/template
RUN set -eux; \
    mv /home/template/bin /home/; \
    mv /home/template/wsproxy /home/;

COPY --chmod=755 entrypoint.sh /
COPY supervisord.conf crontab /
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf.template

ENV PTTCHROME_PAGE_TITLE="PttChrome"
ENV PTTCHROME_SITE="wsstelnet://ws.ptt.cc/bbs"
ENV PTTCHROME_ORIGIN="https://www.ptt.cc"

STOPSIGNAL SIGTERM
EXPOSE 80
VOLUME /home/bbs

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]
