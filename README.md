# tdio/fss-proxy

> CI runner for FE and Backend integrations. (based on nginx/1.19.6)

## How to use this image

```sh
$ docker run --name cmp-ui --net host -v /local/www:/var/www -v /local/etc/nginx.d:/etc/nginx/conf.d tdio/fss-proxy:latest
```

## Envs

* **FSS_PORT** - Nginx port to listen, Defaults to `80`
* **FSS_UPSTREAM** - Proxy to upsteam to router overload: `/api/*`, Defaults to `127.0.0.1:8709`
* **FSS_SPA** - [0, 1], Enable to Fallback to /index.html for Single Page Applications.

```
$ docker run --rm --net host \
  --name xx \
  -v $PWD/dist:/var/www \
  -e FSS_SPA=1 \
  -e FSS_PORT=8080 \
  -e FSS_UPSTREAM=192.168.0.10:8709,192.168.0.11:8709 \
  -d tdio/fss-proxy:latest
```
