#!/bin/sh
set -e

if [ -f /app/.env ]; then
  export $(grep -v '^#' /app/.env | xargs)
fi

exec node server.js