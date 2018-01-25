#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback
USER_ID=${LOCAL_USER_ID:-9001}

echo "Starting with UID : $USER_ID"
useradd --shell /bin/bash -u $USER_ID -o -c "" postgres && echo 'postgres:qwerty' | chpasswd
echo "postgres ALL=(ALL:ALL) NOPASSWD:ALL" | (EDITOR="tee -a" visudo)
export HOME=/home/postgres
chown postgres:postgres -R /home/postgres/
chown postgres:postgres -R /tmp
chmod 750 /home/postgres
usermod -aG sudo postgres
exec /usr/local/bin/gosu postgres "$@"
