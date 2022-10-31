# tdio/fss-proxy

> CI runner for FE and Backend integrations. (based on nginx/1.19.6)

## How to use this image

```sh
$ docker run --name cmp-ui --net host -v /local/www:/var/www -v /local/etc/nginx.d:/etc/nginx/conf.d tdio/fss-proxy:latest
```

## Envs

* **FSS_PORT** - Nginx port to listen, Defaults to `80`
* **FSS_PROXY** - Proxy static resource to a upsteam server, should set `FSS_SPA=0` when proxy mode.
* **FSS_UPSTREAM** - Proxy to upsteam to router overload: `/api/*`, Defaults to `127.0.0.1:8709`
* **FSS_SPA** - [0, 1], Enable to Fallback to /index.html for Single Page Applications.
* **FSS_SSL_PORT** - (Optional) set the ssl port to https listen, Defaults to nil
* **FSS_API_BASE** - (Optional) set the webapp api prefix, Defaults to `/api`
* **FSS_REWRITE_API** (Optional) rewrite backend service to the specific path (`FSS_API_BASE`), Defaults to "1"

```
$ docker run --rm --net host \
  --name xx \
  -v $PWD/dist:/var/www \
  -e FSS_PORT=8080 \
  -e FSS_SPA=0 \
  -e FSS_PROXY=127.0.0.1:3001 \
  -e FSS_UPSTREAM=192.168.0.10:8709,192.168.0.11:8709 \
  -d tdio/fss-proxy:latest
```

### Use as base image

```sh
# build a Dockerfile

$ cat <<'EOF' >Dockerfile.test
FROM tdio/fss-proxy:latest

ADD --chown=nginx:nginx ./dist.tgz /var/www/
EOF

# build with some builtin args

$ docker build --no-cache \
  -t cmp-ui:2.4.1 \
  --build-arg BUILD_VERSION=2.4.1 \
  --build-arg BUILD_GIT_HEAD=10a3720f8de3fc7e0c2cbb6d16a9e2a72d603401 \
  -f ./Dockerfile.test .
```
