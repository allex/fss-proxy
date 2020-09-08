FROM nginx:base

ARG ARG_BUILD_NO=1.0

LABEL version="${ARG_BUILD_NO}" \
      maintainer="allex_wang <allex.wxn@gmail.com>" \
      description="Base image for FE development integration"

ENV FSS_PROXY=127.0
ENV FSS_UPSTREAM=127.0.0.1:8709

ADD .env /
ADD ./nginx /etc/nginx
ADD ./fss-proxy.sh /sbin/

RUN webroot=/var/www \
      && apk add --no-cache curl \
      && mkdir -p ${webroot}/ \
      && chmod +x /sbin/fss-proxy.sh

VOLUME ["/var/cache/nginx","/var/www"]

# may be changed by custom port env ${FSS_PORT}
EXPOSE 80

ENTRYPOINT ["/sbin/fss-proxy.sh"]
