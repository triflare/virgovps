#!/bin/bash
set -euo pipefail

# ensure password env variable or password file exists
if [ -n "${VIRGO_PASS_FILE:-}" ]; then
  if [ ! -f "$VIRGO_PASS_FILE" ]; then
    echo "ERROR: VIRGO_PASS_FILE points to a missing file: $VIRGO_PASS_FILE"
    exit 1
  fi
  VIRGO_PASS="$(<"$VIRGO_PASS_FILE")"
fi

if [ -z "${VIRGO_PASS:-}" ]; then
  echo "ERROR: VIRGO_PASS is not set. Virgo cannot secure the user."
  exit 1
fi

# apply password to virgo
printf '%s\n' "virgo:$VIRGO_PASS" | chpasswd
unset VIRGO_PASS
unset VIRGO_PASS_FILE

# generate SSH Host keys if they don't exist
ssh-keygen -A

echo "Virgo VPS, by Triflare"

# run SSH in the foreground
exec /usr/sbin/sshd -D
