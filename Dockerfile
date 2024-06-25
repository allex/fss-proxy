# syntax = docker/dockerfile:1.3-labs
ARG NGINX_VERSION=1.25.2

FROM nginx:${NGINX_VERSION}-alpine AS builder

COPY --from=harbor.tidu.io/tdio/fss-proxy:2.x /etc/nginx/static_header_set.conf /etc/nginx/
COPY --from=tdio/envgod:1.1.3 /envgod /sbin/

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
  mkdir -p /var/www /var/cache/nginx /var/log/nginx /etc/nginx/ssl
  echo "nginx ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  chmod 0440 /etc/sudoers

  chown nginx.nginx -R /var/www/ /var/cache/nginx/ /var/log/nginx/ /etc/nginx/conf.d/ /etc/nginx/ssl
  rm -f /usr/sbin/nginx-debug
  rm -rf /tmp/*
EOF

ADD init.d /

FROM scratch

ARG BUILD_VERSION
ARG BUILD_GIT_COMMIT
ARG NGINX_VERSION

# Base image for fss-proxy and variant distributions
LABEL tdio.fss-proxy.version="${BUILD_VERSION}" tdio.fss-proxy.commit="${BUILD_GIT_COMMIT}" maintainer="allex_wang <allex.wxn@gmail.com>" description="Base image for FE development integration"

ENV NGINX_VERSION ${NGINX_VERSION}
ENV PKG_RELEASE   1

ENV TZ Asia/Shanghai

ENV FSS_CONF_DIR=/etc/fss-proxy.d/
ENV FSS_VERSION=${BUILD_VERSION}
ENV FSS_PORT=80
ENV FSS_SSL_PORT=
ENV FSS_FORCE_SSL=0
ENV FSS_SSL_ISSUER_DISABLED=true
ENV FSS_SSL_ISSUER_SERVER=https://fe.tidu.io/gen-cert?ipAddrs=%ip&dnsNames=%domain
ENV FSS_SSL_ISSUER_IPADDR=
ENV FSS_SSL_ISSUER_DOMAIN=
ENV FSS_SPA=1
ENV FSS_PROXY=
ENV FSS_UPSTREAM=127.0.0.1:8709
ENV FSS_HEADERS_CSP="script-src 'self' https://* http://* 'unsafe-eval' 'unsafe-inline' blob:; worker-src 'self' 'unsafe-inline' blob:;"
ENV FSS_HEADERS_XSS_PROTECTION="1; mode=block"
ENV FSS_VALID_REFERERS=
ENV FSS_LOCAL_RESOLVERS_DISABLED=false
ENV FSS_LOCAL_RESOLVERS=

# api base for location tilde modifier (^~)
ENV FSS_API_BASE=/api/
ENV FSS_REWRITE_API=1
ENV FSS_SVC_PREFIX=/svc/

COPY --from=builder / /

WORKDIR /var/www
USER nginx

EXPOSE ${FSS_PORT}
ENTRYPOINT ["/sbin/fss-proxy.sh"]
STOPSIGNAL SIGQUIT
CMD []

# Provide some build args for base image derives
ONBUILD ARG VERBOSE=false
ONBUILD ARG BUILD_GIT_HEAD
ONBUILD ARG BUILD_VERSION
ONBUILD ENV BUILD_GIT_HEAD=${BUILD_GIT_HEAD} BUILD_VERSION="${BUILD_VERSION}"
ONBUILD LABEL version="${BUILD_VERSION}" gitref="${BUILD_GIT_HEAD}"
ONBUILD RUN --mount=type=bind,src=/,dst=/tmp/.build set -e \
          && if [ "${VERBOSE:-}" = "true" ]; then \
              set -x; printenv | sort; \
          fi \
          && if [ -z "${BUILD_VERSION}" ]; then \
              echo >&2 'fatal: "${BUILD_VERSION}" is required.'; \
              exit 1; \
          fi \
          && dst_file=/tmp/.build/dist.tgz \
          && if [ -f "$dst_file" ]; then \
              (cd /var/www; \
               tar xzf "$dst_file"; \
               if [ -f ./index.html ]; then \
                  echo "<!-- ${BUILD_VERSION##v} | ${BUILD_GIT_HEAD:-$(date +"%Y%m%d%H%M%S")} -->" >> ./index.html; \
               fi \
              ) \
          fi \
          && echo "build complete."
