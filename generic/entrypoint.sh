#!/bin/bash
set -e

NEW_USER_ID=$(id -u)

cd /home/autoware

if [[ $NEW_USER_ID -ne 0 ]]; then
  if [ -z "$1" ]; then
    exec sudo gosu autoware /bin/bash -l
  else
    exec sudo gosu autoware "$@"
  fi
else
  if [ -z "$1" ]; then
    exec gosu autoware /bin/bash -l
  else
    exec gosu autoware "$@"
  fi
fi
