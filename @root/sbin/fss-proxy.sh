#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:

# ================================================
# Description: fss-proxy bootstrap
# Last Modified: Thu Jan 21, 2021 16:15
# Author: Allex Wang (allex.wxn@gmail.com)
# ================================================

[ -f /.env ] && { set -a; source /.env; set +a; } || { exit $?; }

echo >&2 "start fss-proxy at port ${FSS_PORT} ..."

ngxfile=/etc/nginx/conf.d/default.conf

envgod < $ngxfile > $ngxfile.tmp \
  && mv $ngxfile.tmp $ngxfile \
  && nginx -g 'daemon off;'
