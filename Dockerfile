FROM nginx:base

ARG ARG_BUILD_NO=1.0

LABEL version="${ARG_BUILD_NO}" \
      maintainer="allex_wang <allex.wxn@gmail.com>" \
      description="Base image for FE development integration"

ENV FSS_PROXY=127.0
ENV FSS_PORT=2881

ADD .env /
ADD ./nginx /etc/nginx
ADD ./fss-proxy.sh /sbin/

RUN webroot=/var/www \
      && mkdir -p ${webroot}/ \
      && chmod +x /sbin/fss-proxy.sh

VOLUME ["/var/cache/nginx","/var/www"]

EXPOSE 2881
ENTRYPOINT ["/sbin/fss-proxy.sh"]
