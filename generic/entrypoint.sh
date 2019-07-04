#!/bin/bash
set -e

ORIG_USER_ID=$(id -u autoware)
ORIG_GROUP_ID=$(id -g autoware)
NEW_USER_ID=$(id -u)
NEW_GROUP_ID=$(id -g)

if [ -z "$@" ]; then set - "/bin/bash"; fi

if [[ $NEW_USER_ID -ne 0 ]]; then
  if [ "$ORIG_USER_ID" != "$NEW_USER_ID" ] || [ "$ORIG_GROUP_ID" != "$NEW_GROUP_ID" ]; then
    if [ "$ORIG_USER_ID" != "$NEW_USER_ID" ]; then
      echo "Changing autoware user ID to match your host's user ID ($NEW_USER_ID)." 
      echo "This operation can take a while..."

      usermod --uid $NEW_USER_ID autoware
    fi

    if [ "$ORIG_GROUP_ID" != "$NEW_GROUP_ID" ]; then
      echo "Changing autoware group ID to match your host's group ID ($NEW_GROUP_ID)." 
      echo "This operation can take a while..."

      sudo groupmod --gid $NEW_GROUP_ID autoware
    fi

    find /home/autoware -user $ORIG_USER_ID -exec chown -h $NEW_USER_ID {} \;
  fi

  exec "$@"
else
  exec gosu autoware "$@"
fi
