#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:

# ================================================
# Description: fss-proxy bootstrap
# Last Modified: Wed Jun 03, 2020 18:53
# Author: Allex Wang (allex.wxn@gmail.com)
# ================================================

if [ -f /.env ]; then
  . /.env
fi

ec=$?
[ $ec -eq 0 ] || { exit $ec; }

cfile=/etc/nginx/conf.d/default.conf
vars=`cat "$cfile" |grep '${FSS_.*}' |sed 's/.*\(${FSS_.*}\).*/\1/g'`

echo >&2 "start fss-proxy at port ${FSS_PORT} ..."

envsubst "${vars}" < $cfile > $cfile.tmp \
  && mv $cfile.tmp $cfile \
  && nginx -g 'daemon off;'
