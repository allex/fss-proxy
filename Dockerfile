# syntax = docker/dockerfile:1.3-labs
FROM tdio/nginx:1.21-alpine
RUN <<'eot'
  rm -rf /docker-entrypoint.d /docker-entrypoint.sh
eot

FROM scratch

ARG BUILD_VERSION
ARG BUILD_GIT_HEAD

# Base image for fss-proxy and variant distributions
LABEL fss-proxy.version="${BUILD_VERSION}" fss-proxy.commit="${BUILD_GIT_HEAD}" maintainer="allex_wang <allex.wxn@gmail.com>" description="Base image for FE development integration"

ENV NGINX_VERSION=1.21.3
ENV FSS_VERSION=${BUILD_VERSION}
ENV FSS_PORT=80
ENV FSS_SSL_PORT=
ENV FSS_SPA=1
ENV FSS_PROXY=
ENV FSS_UPSTREAM=127.0.0.1:8709

# api base for location tilde modifier (^~)
ENV FSS_API_BASE=/api/
ENV FSS_REWRITE_API=1

COPY --from=0 / /

ADD init.d /
RUN <<'eot'
  mkdir -p /var/www
eot

EXPOSE ${FSS_PORT}
VOLUME ["/var/cache/nginx"]
ENTRYPOINT ["/sbin/fss-proxy.sh"]

# Provide some build args for base image derives
ONBUILD ARG VERBOSE=0
ONBUILD ARG BUILD_GIT_HEAD
ONBUILD ARG BUILD_VERSION
ONBUILD ARG WWW_DIST=./dist.tgz
ONBUILD ENV BUILD_GIT_HEAD=${BUILD_GIT_HEAD} BUILD_VERSION="${BUILD_VERSION}"
ONBUILD LABEL version="${BUILD_VERSION}" gitref="${BUILD_GIT_HEAD}"
ONBUILD ADD --chown=nginx:nginx ${WWW_DIST} /var/www/
ONBUILD RUN set -e \
          && (if [ "${VERBOSE:-}" = "true" ]; then set -x; printenv | sort; fi) \
          && ([ -n "${BUILD_VERSION}" ] || { echo >&2 'fatal: "${BUILD_VERSION}" is required.'; exit 1; }) \
          && cd /var/www \
          && (if [ -f ./index.html ]; then echo "<!-- ${BUILD_VERSION##v} | ${BUILD_GIT_HEAD:-$(date +"%x %r")} -->" >> ./index.html; fi)
