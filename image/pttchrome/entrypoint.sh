#!/usr/bin/env bash
set -eu

if [ "$1" == "openresty" ] && [ "$EUID" -eq "0" ]; then
    if [ ! -f "/config-created" ]; then
        envsubst '${PTTCHROME_PAGE_TITLE}' \
            < /usr/local/openresty/nginx/PttChrome/index.html.template \
            > /usr/local/openresty/nginx/PttChrome/index.html

        JSNAME="$(basename /usr/local/openresty/nginx/PttChrome/assets/pttchrome.*.js.template .template)"
        envsubst '${PTTCHROME_SITE}' \
            < /usr/local/openresty/nginx/PttChrome/assets/${JSNAME}.template \
            > /usr/local/openresty/nginx/PttChrome/assets/${JSNAME}

        envsubst '${PTTCHROME_ORIGIN}' \
            < /usr/local/openresty/nginx/conf/nginx.conf.template \
            > /usr/local/openresty/nginx/conf/nginx.conf
        touch "/config-created"
    fi
    echo Starting: "$@"
    exec "$@"
fi

exec "$@"
