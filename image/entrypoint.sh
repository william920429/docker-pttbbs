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

        envsubst '${PTTCHROME_ORIGIN}' \
            < /usr/local/openresty/nginx/conf/nginx.conf.template \
            > /usr/local/openresty/nginx/conf/nginx.conf
    
        touch "/config-created"
    fi

    if [ -z "$(ls -A "/home/bbs")" ]; then
        cp -r /etc/skel/. /home/bbs
        cp -r /home/pttbbs/etc /home/bbs/etc
        ln -srnf /home/pttbbs/bin /home/bbs/bin
        chown --no-dereference -R bbs:bbs /home/bbs/
        su bbs -s /bin/sh -c "/home/pttbbs/bin/initbbs -DoIt"
    fi

    su bbs -s /bin/sh -c "/home/pttbbs/bin/shmctl init"

fi

exec "$@"
