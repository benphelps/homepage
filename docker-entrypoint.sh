#!/bin/sh

set -e

export PUID=${PUID:-$(id -u node)}
export PGID=${PUID:-$(id -g node)}

# This is in attempt to preserve the original behavior of the Dockerfile,
# while also supporting the lscr.io /config directory
[ ! -d "/app/config" ] && ln -s /config /app/config

# Set privileges for /app but only if pid 1 user is root.
# If container is run as an unprivileged user, it means owner already handled ownership setup on their own.
# Running chown in that case (as non-root) will cause error
[ "$(id -u)" == "0" ] && chown -R ${PUID}:${PGID} /app

# Drop privileges if root, otherwise run as current user
if [ "$(id -u)" == "0" ]; then
  su-exec ${PUID}:${PGID} "$@"
else
  exec "$@"
fi
