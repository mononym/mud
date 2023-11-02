#!/usr/bin/env bash

export HOME=/home/ubuntu
# Ignore error in case the server is not up, for example. Just assume this works or does not apply.
/home/ubuntu/apps/mud/bin/prod stop || true