# syntax = docker/dockerfile:1.3-labs
ARG NGX_VER=1.23.3
FROM nginx:${NGX_VER}-alpine

RUN <<'eot'
  rm -rf /docker-entrypoint.d /docker-entrypoint.sh
eot

COPY --from=harbor.tidu.io/tdio/fss-proxy:2.x /etc/nginx/static_header_set.conf /etc/nginx/
COPY --from=tdio/envgod:latest /envgod /sbin/

FROM scratch

ARG BUILD_VERSION
ARG BUILD_GIT_HEAD

# Base image for fss-proxy and variant distributions
LABEL tdio.fss-proxy.version="${BUILD_VERSION}" tdio.fss-proxy.commit="${BUILD_GIT_HEAD}" maintainer="allex_wang <allex.wxn@gmail.com>" description="Base image for FE development integration"

ENV NGINX_VERSION ${NGX_VER}
ENV PKG_RELEASE   1

ENV TZ Asia/Shanghai

ENV FSS_VERSION=${BUILD_VERSION}
ENV FSS_PORT=80
ENV FSS_SSL_PORT=
ENV FSS_SPA=1
ENV FSS_PROXY=
ENV FSS_UPSTREAM=127.0.0.1:8709
ENV FSS_HEADERS_CSP="script-src 'self' https://* http://* 'unsafe-eval' 'unsafe-inline' blob:; worker-src 'self' 'unsafe-inline' blob:;"
ENV FSS_HEADERS_XSS_PROTECTION="1; mode=block"
ENV FSS_VALID_REFERERS=

# api base for location tilde modifier (^~)
ENV FSS_API_BASE=/api/
ENV FSS_REWRITE_API=1
ENV FSS_SVC_PREFIX=/svc/

COPY --from=0 / /

ADD init.d /
RUN <<-'eot'
  sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
  apk add --no-cache sudo
  apk add --no-cache libcap && setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx
  mkdir -p /var/www /var/patch
  echo "nginx ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  chmod 0440 /etc/sudoers
  touch /var/run/nginx.pid
  chown nginx.nginx -R /var/www/ /var/cache/nginx/ /var/log/nginx/ /etc/nginx/conf.d/ /var/run/nginx.pid
  rm -rf /tmp && (umask 0; mkdir /tmp)
eot

WORKDIR /var/www
USER nginx

EXPOSE ${FSS_PORT}
VOLUME ["/var/cache/nginx"]
ENTRYPOINT ["/sbin/fss-proxy.sh"]

# Provide some build args for base image derives
ONBUILD ARG VERBOSE=0
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
