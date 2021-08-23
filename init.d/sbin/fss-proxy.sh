#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:

# ================================================
# Description: fss-proxy bootstrap
# Last Modified: Mon Aug 23, 2021 10:03
# Author: Allex Wang (allex.wxn@gmail.com)
# ================================================

[ "${VERBOSE/true/1}" = "1" ] && set -x

if [ $# -gt 0 ]; then
  nginx "$@"
  exit $?
fi

[ -f /.env ] && { set -a; source /.env; set +a; } || { exit $?; }

apply_patches="${PATCH_FILE:-}"
if [ -f "$apply_patches" ]; then
  chmod +x $apply_patches
  $apply_patches
fi

echo >&2 "start fss-proxy at port ${FSS_PORT} ..."
ngxfile=/etc/nginx/conf.d/default.conf
envgod < $ngxfile > $ngxfile.tmp && mv $ngxfile.tmp $ngxfile \
  && nginx -g 'daemon off;'
