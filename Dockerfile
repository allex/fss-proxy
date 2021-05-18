FROM tdio/nginx:2

ARG BUILD_TAG
ARG BUILD_GIT_HEAD

# Base image for fss-proxy and variant distributions
LABEL version="${BUILD_TAG}" maintainer="allex_wang <allex.wxn@gmail.com>" description="Base image for FE development integration"

ENV BUILD_TAG=${BUILD_TAG}
ENV BUILD_GIT_HEAD=${BUILD_GIT_HEAD}

# default ngx expose port
ENV FSS_PORT=80
ENV FSS_PROXY=
ENV FSS_UPSTREAM=127.0.0.1:8709

ADD init.d /
RUN webroot=/var/www \
  && mkdir -p ${webroot}/ \
  && chmod +x /sbin/fss-proxy.sh

VOLUME ["/var/cache/nginx"]

ENTRYPOINT ["/sbin/fss-proxy.sh"]
