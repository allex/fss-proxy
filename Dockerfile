FROM tdio/nginx:2
FROM scratch

ARG BUILD_VERSION
ARG BUILD_GIT_HEAD

# Base image for fss-proxy and variant distributions
LABEL version="${BUILD_VERSION}" maintainer="allex_wang <allex.wxn@gmail.com>" description="Base image for FE development integration"

ENV BUILD_VERSION=${BUILD_VERSION}
ENV BUILD_GIT_HEAD=${BUILD_GIT_HEAD}

# default ngx expose port
ENV FSS_PORT=80
ENV FSS_PROXY=
ENV FSS_UPSTREAM=127.0.0.1:8709
ENV FSS_SPA=1

COPY --from=0 / /
COPY --from=tdio/envgod:latest /envgod /sbin/

ADD init.d /
RUN webroot=/var/www \
  && mkdir -p ${webroot}/ \
  && chmod +x /sbin/fss-proxy.sh

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
ONBUILD RUN sh /tmp/on-build.sh
