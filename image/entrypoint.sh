#!/usr/bin/env bash
set -eu

if [ "$1" == "/usr/bin/supervisord" ] && [ "$EUID" -eq "0" ]; then

    if [ ! -f "/config-created" ]; then

        envsubst '${PTTCHROME_PAGE_TITLE}' \
            < /usr/local/openresty/nginx/html/index.html.template \
            > /usr/local/openresty/nginx/html/index.html

        JSNAME="$(basename /usr/local/openresty/nginx/html/assets/pttchrome.*.js.template .template)"
        envsubst '${PTTCHROME_SITE}' \
            < /usr/local/openresty/nginx/html/assets/${JSNAME}.template \
            > /usr/local/openresty/nginx/html/assets/${JSNAME}

        envsubst '${PTTCHROME_ORIGIN},${BBS_LOGIND_ADDR},${BBS_LOGIND_PORT}' \
            < /usr/local/openresty/nginx/conf/nginx.conf.template \
            > /usr/local/openresty/nginx/conf/nginx.conf
    
        touch "/config-created"
    fi

    if [ -z "$(ls "/home/bbs")" ]; then
        cp -r /home/template/. /home/bbs/
        chown -R bbs:bbs /home/bbs/
        ln -srnf /home/bin /home/bbs/bin
    fi

    su bbs -s /bin/sh -c "/home/bin/shmctl init"

fi

exec "$@"
