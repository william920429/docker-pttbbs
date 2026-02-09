#!/usr/bin/env bash
set -eu

exec_as(){
    exec \
        env HOME=/home/bbs SHELL=/usr/sbin/nologin USER=bbs LOGNAME=bbs \
        setpriv --reuid bbs --regid bbs --clear-groups --no-new-privs -- \
        "$@"
}

setup_bbs_home(){
    if [ -z "$(ls -A "/home/bbs")" ]; then
        cp -a /usr/local/pttbbs/etc /home/bbs/etc
        mkdir /home/bbs/backup
        ln -srnf /usr/local/pttbbs/bin /home/bbs/bin
        ln -srnf /dev/shm /home/bbs/run
        chown --no-dereference -R bbs:bbs /home/bbs/
        runuser -u bbs -- /usr/local/pttbbs/bin/initbbs -DoIt
    fi
}

if [ "$EUID" -eq "0" ]; then
    case "$(basename "$1")" in
        logind)
            setup_bbs_home
            runuser -u bbs -- /usr/local/pttbbs/bin/shmctl init
            echo Starting: "$@"
            exec_as "$@"
        ;;
        supercronic)
            echo Starting: "$@"
            exec_as "$@"
        ;;
    esac
fi

exec "$@"
