#!/usr/bin/env bash

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
INTERNAL_SSH_KEY="$HOME/.ssh/id_rsa"

## Args
APPID="$1"

if [ "x$APPID" = "x" ]; then
    echo "error: variable 'APPID' is required...exiting!"
    exit 2;
fi

if [ -f $HOME/setenv-management.sh ]; then
    . $HOME/setenv-management.sh
fi

MANAGEMENT_LINUX_HOST=$MANAGEMENT_LINUX_HOST_1
MANAGEMENT_LINUX_HOST_USER=$MANAGEMENT_LINUX_HOST_1_USER

if [ "x$INTERNAL_SSH_KEY" = "x" ]; then
    echo "error: variable INTERNAL_SSH_KEY is required...exiting!"
    exit 2;
fi

if [ ! -f $INTERNAL_SSH_KEY ]; then
    echo "error: internal server private key file at path [$INTERNAL_SSH_KEY] does not exist...exiting!"
    exit 2;
fi

if [ "x$MANAGEMENT_LINUX_HOST" = "x" ]; then
    echo "error: variable MANAGEMENT_LINUX_HOST is required...exiting!"
    exit 2;
fi

if [ "x$MANAGEMENT_LINUX_HOST_USER" = "x" ]; then
    echo "error: variable MANAGEMENT_LINUX_HOST_USER is required...exiting!"
    exit 2;
fi

##sync to management
rsync -arvz -e "ssh $SSH_OPTS -i $INTERNAL_SSH_KEY" --delete $HOME/$APPID/ $MANAGEMENT_LINUX_HOST_USER@$MANAGEMENT_LINUX_HOST:$HOME/$APPID/