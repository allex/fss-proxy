#!/bin/sh
#by @allex_wang

set -e

ME=$(basename "$0")

# shellcheck disable=SC1091
. "$FSS_HOME"/libexec/fss-proxy/functions

# Evaluate ngx config template with envs
auto_envsubst() {
  local template_dir="${NGINX_ENVSUBST_TEMPLATE_DIR:-/etc/nginx/templates}"
  local suffix="${NGINX_ENVSUBST_TEMPLATE_SUFFIX:-.template}"
  local output_dir="${NGINX_ENVSUBST_OUTPUT_DIR:-/etc/nginx/conf.d}"

  local template relative_path output_path subdir
  [ -d "$template_dir" ] || return 0
  if [ ! -w "$output_dir" ]; then
    log "$ME: ERROR: $template_dir exists, but $output_dir is not writable"
    return 0
  fi
  find "$template_dir" -follow -type f -name "*$suffix" -print | while read -r template; do
    relative_path="${template#$template_dir/}"
    output_path="$output_dir/${relative_path%$suffix}"
    subdir=$(dirname "$relative_path")
    # create a subdirectory where the template file exists
    mkdir -p "$output_dir/$subdir"
    envgod -env-subst <"$template" | sed "/^ *$/d" > "$output_path"
    success "envgod: '$output_path'"
  done
}

auto_envsubst

exit 0
