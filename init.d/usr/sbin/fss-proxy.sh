#!/bin/sh
# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:
# Enterpoint for fss-proxy (by @allex_wang | MIT Licensed)

set -eu

PROG=$(basename "$0")
FSS_HOME="$(cd -P -- "$(dirname -- "$(readlink -f "$0")")/.." && pwd -P)"

[ -n "${FSS_HOME:-}" ] || {
  echo >&2 "fatal: environ variable 'FSS_HOME' is not set."
  exit 1
}

export FSS_HOME

# shellcheck disable=SC1091
. "$FSS_HOME"/libexec/fss-proxy/functions

# set log output to /dev/null if FSS_QUIET_LOGS is true
if is_true "${FSS_QUIET_LOGS-0}" ; then
  exec 3>/dev/null
else
  exec 3>&1
fi

USAGE="
Commands:
  reload          Reload nginx configuration
  status          Show nginx status

Options:
  -x, --verbose   Enable trace for debug
  -d, --daemonize Run nginx as system daemon (in background)
  --load-env      Load environment variables from env file specified by \$FSS_ENV_FILE
                  (can also be enabled via \$FSS_LOAD_ENV)
  -h, --help      Show this help message

Examples:
  $PROG                    Start nginx in foreground mode
  $PROG -d                 Start nginx in daemon mode
  $PROG reload             Reload nginx configuration
  $PROG status             Show nginx status
  $PROG --load-env         Load environment and start nginx"

usage() {
  echo "Usage: $PROG [options] [command]"
  echo "$USAGE"
  exit 0
}

load_envfile () {
  # load environment variables from /.env
  env_file=${FSS_ENV_FILE:-/.env}
  if is_true "$load_env" && test -f "$env_file" ; then
    # shellcheck disable=SC1090
    { set -a; . "$env_file"; set +a; }
    success "Environment loaded successfully"
  fi
}

# Load configuration and setup environment
load_configuration() {
  log "FSS-Proxy $FSS_VERSION (based on nginx $NGINX_VERSION, envgod $(envgod -v))"

  find "$FSS_HOME/libexec/" -follow -type f -print | sort -V | while read -r f; do
    case "$f" in
      *.envsh)
        log "include '$f'";
        # shellcheck disable=SC1090
        . "$f"
        ;;
      *.sh)
        if [ -x "$f" ]; then
          log "=> '$f'";
          "$f"
        else
          # warn on shell scripts without exec bit
          warn "Ignoring $f, not executable";
        fi
        ;;
      *) ;;
    esac
  done
}

nginx_reload() {
  log "Reloading nginx configuration..."
  if nginx -s reload 2>/dev/null; then
    success "Nginx configuration reloaded successfully"
  else
    error "Failed to reload nginx configuration"
    return 1
  fi
}

nginx_status() {
  if pgrep nginx >/dev/null 2>&1; then
    success "Nginx is running"
    nginx -v 2>&1 | head -1
  else
    warn "Nginx is not running"
    return 1
  fi
}

load_env=${FSS_LOAD_ENV:-}
runas_daemon=

# parse global options and command
command=
while test $# -ne 0
do
  case "$1" in
    -d | --daemonize)
      runas_daemon=1
      ;;
    --load-env)
      load_env=1
      ;;
    -h | --help)
      usage
      ;;
    -x | --verbose)
      export VERBOSE=1
      ;;
    reload | status)
      command="$1"
      ;;
    *)
      break
      ;;
  esac
  shift
done

if is_true "${VERBOSE:-}"; then
  set -x
fi

load_envfile

if [ -n "$command" ]; then
  case "$command" in
    reload)
      load_configuration
      nginx_reload
      exit $?
      ;;
    status)
      load_configuration
      nginx_status
      exit $?
      ;;
  esac
else
  if [ $# -eq 0 ]; then
    load_configuration
    if is_true "${runas_daemon}"; then
      info "Starting nginx in daemon mode..."
      eval set -- "nginx"
    else
      info "Starting nginx in foreground mode..."
      eval set -- "nginx -g 'daemon off;'"
    fi
  fi
  exec "$@"
fi
