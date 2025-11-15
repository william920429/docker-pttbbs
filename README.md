# Docker PttBBS

## Features
 - [PttBBS](https://github.com/ptt/pttbbs) installed
 - [PttChrome](https://github.com/robertabcd/PttChrome) installed
 - [OpenResty](https://openresty.org/) installed ([image](https://hub.docker.com/r/openresty/openresty))

## How to install
### Copy example files
```shell
cp ./example/.env ./
cp ./example/docker-compose.yml ./
```
### Configure environment variable
 - `TZ` Timezone
 - `PTTCHROME_PORT` PttChrome Port to expose
 - `PTTCHROME_PAGE_TITLE` PttChrome page title
 - `PTTCHROME_SITE` BBS websocket host to connect.
   - `wstelnet://YOUR-SERVER-URL/bbs` for unencrypted connection
   - `wsstelnet://YOUR-SERVER-URL/bbs` for encryption over TLS
 - `PTTCHROME_ORIGIN` PttChrome URL for origin check.
   - `http://YOUR-SERVER-URL` for unencrypted connection
   - `https://YOUR-SERVER-URL` for encryption over TLS

It is recommended to use behind a reverse proxy with HTTPS.

### Run
```shell
docker compose up -d
```

## Reference
1. PttBBS <https://github.com/ptt/pttbbs>
2. PttChrome <https://github.com/robertabcd/PttChrome>
3. Unofficial Docker image <https://github.com/bbsdocker/imageptt>
4. OpenResty <https://openresty.org/> <https://hub.docker.com/r/openresty/openresty>

> PS. `pttbbs.conf` and `bindports.conf` are copied and modified from [imageptt](https://github.com/bbsdocker/imageptt)
