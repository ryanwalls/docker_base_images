#!/usr/bin/env bash
# R10K Entry Point

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
REMOTE=${REMOTE:-}
CRON_TIME="${CRON_TIME:-}"
CACHEDIR=${CACHEDIR:-/var/cache/r10k}

# Log message
log(){
  echo "[$(date "+%Y-%m-%dT%H:%M:%S%z") - $(hostname)] ${*}"
}

# Generate R10K configuration
generate_configuration(){
  # Make sure R10K configuration directory exists
  mkdir -p /etc/puppetlabs/r10k

  # Create R10K configuration
  if [[ ! -s /etc/puppetlabs/r10k/r10k.yaml ]]; then
    cat << EOF > /etc/puppetlabs/r10k/r10k.yaml
# The location to use for storing cached Git repos
:cachedir: '${CACHEDIR}'

# A list of git repositories to create
:sources:
  # This will clone the git repository and instantiate an environment per
  # branch in /etc/puppetlabs/code/environments
  :main:
    remote: '${REMOTE}'
    basedir: '/etc/puppetlabs/code/environments'
EOF
  fi
}

# Install cron job
run_cron(){
  IFS=' '
  cmd="${*:-}"

  log "Run '${cmd}'"
  eval "$cmd"

  log "Setup the cron job (${CRON_TIME})"
  echo "${CRON_TIME} sh -c '${cmd}'" > /etc/crontabs/root
  exec crond -f -l 6
}

# Main function
main(){
  generate_configuration

  if [[ -n "$CRON_TIME" ]]; then
    run_cron "${@:-}"
  else
    exec "${@:-}"
  fi
}

main "${@:-}"
