#!/bin/bash

# ensure password env variable exists
if [ -z "$VIRGO_PASS" ]; then
  echo "ERROR: VIRGO_PASS is not set. Virgo cannot secure the user."
  exit 1
fi

# apply password to virgo
echo "virgo:$VIRGO_PASS" | chpasswd

# generate SSH Host keys if they don't exist
ssh-keygen -A

echo "Virgo VPS, by Triflare"

# run SSH in the foreground
exec /usr/sbin/sshd -D
