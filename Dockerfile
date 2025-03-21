# syntax = docker/dockerfile:1.3-labs
ARG NGINX_VERSION=1.25.2

FROM nginx:${NGINX_VERSION}-alpine AS builder

COPY --from=tdio/envgod:1.1.7 /envgod /sbin/

ENV nginx_dirs="/var/www/ /var/cache/nginx/ /var/log/nginx/ /etc/nginx/templates/ /etc/nginx/conf.d/ /etc/nginx/ssl"

RUN <<-'EOF'
  # cleanup and init configure
  rm -rf /docker-entrypoint.d /docker-entrypoint.sh
  sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

  # remove unused packages
  apk del nginx-module-image-filter nginx-module-geoip nginx-module-xslt nginx-module-njs

  # add default TZ to Asia/Shanghai
  TZ=Asia/Shanghai \
    && cp -s /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && tar -cf - /usr/share/zoneinfo/${TZ} | (apk del --no-cache tzdata && tar -C / -xf -)

  # add dependencies for rootless
  apk add --no-cache sudo
  apk add --no-cache libcap && setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx

  # add nginx to sudoers
  mkdir -p $nginx_dirs
  echo "nginx ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  chmod 0440 /etc/sudoers

  rm -f /usr/sbin/nginx-debug
  rm -rf /tmp/*

  ln -sf ../usr/sbin/fss-proxy.sh /sbin/fss-proxy.sh
EOF

ADD init.d /

RUN <<-'EOF'
  chown nginx.nginx -R $nginx_dirs
EOF

FROM scratch

ARG BUILD_VERSION
ARG BUILD_GIT_COMMIT
ARG NGINX_VERSION

# Base image for fss-proxy and variant distributions
LABEL tdio.fss-proxy.version="${BUILD_VERSION}" tdio.fss-proxy.commit="${BUILD_GIT_COMMIT}" maintainer="allex_wang <allex.wxn@gmail.com>" description="Base image for FE development integration"

ENV NGINX_VERSION ${NGINX_VERSION}
ENV PKG_RELEASE   1

ENV TZ Asia/Shanghai

ENV FSS_VERSION=${BUILD_VERSION}
ENV FSS_PORT=80
ENV FSS_SSL_PORT=
ENV FSS_FORCE_SSL=0
ENV FSS_SSL_ISSUER_ENABLE=false
ENV FSS_SSL_ISSUER_SERVER=https://fe.tidu.io/gen-cert?ipAddrs=%ip&dnsNames=%domain
ENV FSS_SSL_ISSUER_IPADDR=
ENV FSS_SSL_ISSUER_DOMAIN=
ENV FSS_SPA=1
ENV FSS_PROXY=
ENV FSS_UPSTREAM=127.0.0.1:8709
ENV FSS_HEADERS_CSP="script-src 'self' https://* http://* 'unsafe-eval' 'unsafe-inline' blob:; worker-src 'self' 'unsafe-inline' blob:;"
ENV FSS_HEADERS_XSS_PROTECTION="1; mode=block"
ENV FSS_CONTEXT_PATH=/
ENV FSS_FIX_HTTPS_COOKIE=true

# Options for auto load env file
# the `FSS_LOAD_ENV` can be set by `fss-proxy.sh --load-env` and the env file
# path can be set by `FSS_ENV_FILE`, default is /.env
ENV FSS_LOAD_ENV= \
    FSS_ENV_FILE=

# ref: [valid_referers](https://nginx.org/en/docs/http/ngx_http_referer_module.html#valid_referers)
ENV FSS_VALID_REFERERS=

ENV FSS_LOCAL_RESOLVERS_DISABLED=false
ENV FSS_LOCAL_RESOLVERS=

# api base for location tilde modifier (^~)
ENV FSS_API_BASE=/api/
ENV FSS_REWRITE_API=1
ENV FSS_SVC_PREFIX=/svc/

COPY --from=builder / /

WORKDIR /var/www

EXPOSE ${FSS_PORT}
ENTRYPOINT ["/sbin/fss-proxy.sh"]
STOPSIGNAL SIGQUIT
CMD []

# Provide some build args for base image derives
ONBUILD ARG BUILD_VERBOSE=false
ONBUILD ARG BUILD_GIT_HEAD
ONBUILD ARG BUILD_VERSION
ONBUILD ARG BUILD_ADD_DIST=true
ONBUILD ARG USER=nginx
ONBUILD ENV BUILD_GIT_HEAD=${BUILD_GIT_HEAD} BUILD_VERSION="${BUILD_VERSION}"
ONBUILD LABEL version="${BUILD_VERSION}" gitref="${BUILD_GIT_HEAD}"
ONBUILD USER ${USER}
ONBUILD RUN --mount=type=bind,src=/,dst=/tmp/.build <<-'EOF'
set -eu
log () { echo "[tdio/fss-proxy]: $*"; }
log "Now running builder as $(whoami)"
[ "${BUILD_VERBOSE:-}" = "true" ] && { printenv | sort; set -x; }
dst_file=/tmp/.build/dist.tgz
if [ ! -f "$dst_file" ]; then
	exit 0
else
	if [ "${BUILD_ADD_DIST:-}" = "false" ]; then
		log "Skipping extraction of dist files as 'BUILD_ADD_DIST' is set to false."
		exit 0
	fi
fi
[ -n "${BUILD_VERSION}" ] || { log 'Error: "${BUILD_VERSION}" is required.'; exit 1; }
(cd /var/www
tar xzf "$dst_file"
if [ -f ./index.html ]; then
	echo "<!-- ${BUILD_VERSION##v} | ${BUILD_GIT_HEAD:-$(date +"%Y%m%d.%H%M%S")} -->" >> ./index.html
fi)
log "Build complete."
EOF
