# tdio/cmp-ui-base

> Base image for front-end SPA project

## How to use this image

```sh
$ docker run --name cmp-ui --net host -v /local/www:/var/www -v /local/etc/nginx.d:/etc/nginx/conf.d tdio/cmp-ui-base:latest
```

## ENVs Usage

* **FSS_PORT** - nginx port to listen, defaults to `80`
* **FSS_UPSTREAM** - `/api/*` endpoint, defaults to `127.0.0.1:8709`

```
$ docker run --name xx --rm --net host \
     -e FSS_PORT=8080 \
     -e FSS_UPSTREAM=192.168.0.10:8709,192.168.0.11:8709 \
     -d tdio/cmp-ui-base:2.0.0
```
