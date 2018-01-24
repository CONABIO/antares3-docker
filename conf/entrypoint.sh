#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback
USER_ID=${LOCAL_USER_ID:-9001}

echo "Starting with UID : $USER_ID"
useradd --shell /bin/bash -u $USER_ID -o -c "" -m  madmex_user && echo 'madmex_user:qwerty' | chpasswd
useradd --shell /bin/bash -u $USER_ID -o -c "" postgres 
echo "madmex_user ALL=(ALL:ALL) NOPASSWD:ALL" | (EDITOR="tee -a" visudo)
export HOME=/home/madmex_user
chown madmex_user:madmex_user /home/madmex_user/
chmod 750 /home/madmex_user
usermod -aG sudo madmex_user
exec /usr/local/bin/gosu madmex_user "$@"
