#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:

# ================================================
# Description: fss-proxy bootstrap
# Last Modified: Wed Apr 01, 2020 10:46
# Author: Allex Wang (allex.wxn@gmail.com)
# ================================================

echo >&2 "start fss-proxy ..."

export FSS_HOST=${FSS_HOST:-fss.proxy}
export FSS_PORT=${FSS_PORT:-80}
export FSS_PROXY=${FSS_PROXY:-127.0.0.1:8081}

if [ -z "$FSS_UPSTREAM" ]; then
  echo >&2 'fatal: the env "${FSS_UPSTREAM}" is mandatory required'
  exit 1
fi

cfile=/etc/nginx/conf.d/default.conf
vars=`cat "$cfile" |grep '${FSS_.*}' |sed 's/.*\(${FSS_.*}\).*/\1/g'`

envsubst "${vars}" < $cfile > $cfile.tmp \
  && mv $cfile.tmp $cfile \
  && nginx
