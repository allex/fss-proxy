#!/bin/sh
# vim:sw=2:ts=2:sts=2:et

set -eu

LC_ALL=C

# shellcheck disable=SC1091
. "${FSS_CONF_DIR}/.helpers/functions"

# skip if disabled
if is_true "${FSS_LOCAL_RESOLVERS_DISABLED:-}" ; then
  exit 0
fi

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

resolvers=${FSS_LOCAL_RESOLVERS:-}

if [ -z "$resolvers" ]; then
  resolvers=$(awk 'BEGIN{ORS=" "} $1=="nameserver" {if ($2 ~ ":") {print "["$2"]"} else {print $2}}' /etc/resolv.conf | xargs)
fi

confpath=/etc/nginx/conf.d/resolvers.conf

if [ "$resolvers" ]; then
  echo "resolver $resolvers;" > $confpath
  success "success write '$confpath' with resolvers '$resolvers'"
else
  error "invalid resolvers"
fi
