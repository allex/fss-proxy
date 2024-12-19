#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:

# auto issure ssl certificate files.
# by @allex_wang

set -eu

LC_ALL=C

# shellcheck disable=SC1091
. "${FSS_HOME}/libexec/fss-proxy/functions"

sh_c='sh -c'
cert_dir=/etc/nginx/ssl

if is_true "${VERBOSE:-}"; then
  set -x
fi

# auto issuer is disabled
if ! is_true "${FSS_SSL_ISSUER_ENABLE:-}" ; then
  if [ -n "${FSS_SSL_PORT:-}" ] ; then
    if [ ! -r $cert_dir/tls.key ] || [ ! -r $cert_dir/tls.crt ]; then
      die "https is enabled but cert files not found, set \"FSS_SSL_ISSUER_ENABLE=true\" to auto issue cert files"
    fi
  fi
  info "The automatic issuance of TLS cert files is disabled. set \"FSS_SSL_ISSUER_ENABLE=true\" to enable it."
  exit 0
fi

cert_issuer=${FSS_SSL_ISSUER_SERVER:-}

mkdir -p $cert_dir
touch $cert_dir/tls.key 2>/dev/null || {
  error "can not modify $cert_dir/tls.key (read-only file system?)"
  exit 0
}

if [ -z "$cert_issuer" ]; then
  die "ssl issuer server not set, please set \"FSS_SSL_ISSUER_SERVER\""
fi

ssl_ips=${FSS_SSL_ISSUER_IPADDR:-$(ip route get 1.1.1.1 | head -n 1 | sed 's#.* src \([^ ]*\).*#\1#g')}
ssl_domain=${FSS_SSL_ISSUER_DOMAIN:-}
cert_issuer=$(echo "$cert_issuer" | sed "s/%ip/$ssl_ips/g;s/%domain/$ssl_domain/g")

$sh_c "curl -Lfk --no-progress-meter '${cert_issuer}' | tar -C $cert_dir -xf-" \
  && success "auto issue ssl certificate success" \
  || exit 1
