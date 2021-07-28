FROM tdio/nginx:2

ARG BUILD_VERSION
ARG BUILD_GIT_HEAD

# Base image for fss-proxy and variant distributions
LABEL version="${BUILD_VERSION}" baseref="${BUILD_GIT_HEAD}" maintainer="allex_wang <allex.wxn@gmail.com>" description="Base image for FE development integration"

# default ngx expose port
ENV FSS_PORT=80
ENV FSS_PROXY=127.0
ENV FSS_UPSTREAM=127.0.0.1:8709

ONBUILD ARG BUILD_VERSION
ONBUILD ENV BUILD_VERSION=${BUILD_VERSION}
ONBUILD ARG BUILD_GIT_HEAD
ONBUILD ENV BUILD_GIT_HEAD=${BUILD_GIT_HEAD}

ADD init.d /
RUN webroot=/var/www \
  && mkdir -p ${webroot}/ && cp -s /usr/share/nginx/html/* ${webroot} \
  && chmod +x /sbin/fss-proxy.sh

VOLUME ["/var/cache/nginx"]

ENTRYPOINT ["/sbin/fss-proxy.sh"]
