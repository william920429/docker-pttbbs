# Docker PttBBS

## Features
 - [PttChrome](https://github.com/robertabcd/PttChrome) bundled
 - Use binary from [imageptt](https://github.com/bbsdocker/imageptt) [docker image](https://github.com/bbsdocker/imageptt/pkgs/container/imageptt)
 - Use [OpenResty](https://openresty.org/) [docker image](https://hub.docker.com/r/openresty/openresty) for serving websocket

## How to install
### Copy example files
```shell
cp ./example/.env ./
cp ./example/docker-compose.yml ./
```
### Configure environment variable
 - `TZ` Timezone
 - `PTTCHROME_PAGE_TITLE` PttChrome page title
 - `PTTCHROME_SITE` BBS websocket host to connect.
   - `wstelnet://YOUR-SERVER-URL/bbs` for unencrypted connection
   - `wsstelnet://YOUR-SERVER-URL/bbs` for encryption over TLS
 - `PTTCHROME_ORIGIN` PttChrome URL for origin check.
   - `http://YOUR-SERVER-URL` for unencrypted connection
   - `https://YOUR-SERVER-URL` for encryption over TLS

It is recommended to use behind a reverse proxy with HTTPS.

### Configure docker-compose.yml
```yml
pttbbs:
  ports:
    - 3001:80
```
You can change the port number to expose.

### Run
```shell
docker compose up -d
```

## Reference
1. PttBBS <https://github.com/ptt/pttbbs>
2. PttChrome <https://github.com/robertabcd/PttChrome>
3. Unofficial Docker image <https://github.com/bbsdocker/imageptt> <https://github.com/bbsdocker/imageptt/pkgs/container/imageptt>
4. OpenResty <https://openresty.org/> <https://hub.docker.com/r/openresty/openresty>
