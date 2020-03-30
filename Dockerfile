FROM nginx_base:latest

LABEL version="1.0" \
      maintainer="allex_wang <allex.wxn@gmail.com>" \
      description="Base image for FE and Backend development integration"

ENV FSS_PROXY=127.0.0.1:8081
ENV FSS_UPSTREAM=

ADD ./nginx /etc/nginx
ADD ./fss-proxy.sh /sbin/

RUN webroot=/var/www \
      && mkdir -p ${webroot}/ \
      && chmod +x /sbin/fss-proxy.sh

VOLUME ["/var/cache/nginx"]

EXPOSE 80
ENTRYPOINT ["/sbin/fss-proxy.sh"]
