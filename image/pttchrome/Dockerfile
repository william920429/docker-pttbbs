ARG DEBIAN_VERSION="bookworm"

FROM openresty/openresty:${DEBIAN_VERSION}

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

COPY --chmod=755 entrypoint.sh /
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf.template
COPY wsproxy.lua /usr/local/openresty/nginx/

ENV PTTCHROME_PAGE_TITLE="PttChrome" \
    PTTCHROME_SITE="wstelnet://localhost:21900/ws" \
    PTTCHROME_ORIGIN="http://localhost:21900" \
    LOGIND_ADDR="app" \
    LOGIND_PORT="23"

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD ["openresty", "-g", "daemon off;"]
