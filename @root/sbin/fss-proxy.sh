#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:

# ================================================
# Description: fss-proxy bootstrap
# Last Modified: Wed Nov 25, 2020 14:16
# Author: Allex Wang (allex.wxn@gmail.com)
# ================================================

[ -f /.env ] && { set -a; source /.env; set +a; } || { exit $?; }

echo >&2 "start fss-proxy at port ${FSS_PORT} ..."

ngxfile=/etc/nginx/conf.d/default.conf
vars=`envsubst --variables "$(cat $ngxfile)" |sort |uniq |awk '/^[A-Z0-9\d_]+$/{print "${"$1"}"}'`

envsubst "${vars}" < $ngxfile > $ngxfile.tmp \
  && mv $ngxfile.tmp $ngxfile \
  && nginx -g 'daemon off;'
