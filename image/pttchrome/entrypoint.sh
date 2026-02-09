#!/usr/bin/env bash
set -eu

if [ "$1" == "openresty" ] && [ "$EUID" -eq "0" ]; then
    if [ ! -f "/config-created" ]; then
        envsubst '${PTTCHROME_PAGE_TITLE}' \
            < /usr/local/openresty/nginx/html/index.html.template \
            > /usr/local/openresty/nginx/html/index.html

        JSNAME="$(basename /usr/local/openresty/nginx/html/assets/pttchrome.*.js.template .template)"
        envsubst '${PTTCHROME_SITE}' \
            < /usr/local/openresty/nginx/html/assets/${JSNAME}.template \
            > /usr/local/openresty/nginx/html/assets/${JSNAME}

        envsubst '${PTTCHROME_ORIGIN} ${LOGIND_ADDR} ${LOGIND_PORT}' \
            < /usr/local/openresty/nginx/conf/nginx.conf.template \
            > /usr/local/openresty/nginx/conf/nginx.conf
        touch "/config-created"
    fi
    echo Starting: "$@"
    exec "$@"
fi

exec "$@"
