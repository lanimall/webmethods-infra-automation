#!/usr/bin/env bash

THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR"
BUILD_DIR="$BASEDIR/build"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

## load common vars
. $BASEDIR/common/scripts/build_common.sh

## Args
ENVTARGET="$1"
APP_NAME="saggov_shared_management_azure"

## validate the env values and exit if invalid
validate_args_env $ENVTARGET

## validate the APP_NAME and exit if invalid
if [ "x$APP_NAME" = "x" ]; then
    echo "error: variable 'APP_NAME' is required...exiting!"
    exit 2;
fi

## build appid for the env
APPID=$(build_token_value $APP_NAME $ENVTARGET)

CONFIGS_BASE_DIR=$HOME/mydevsecrets/$APP_NAME/configs/$ENVTARGET
BASTION_SSH_PRIV_KEY_PATH=$CONFIGS_BASE_DIR/certs/ssh/sshkey_id_rsa_bastion
SETENV_BASTION_PATH=$CONFIGS_BASE_DIR/envs/setenv-bastion.sh

if [ "x$BASTION_SSH_PRIV_KEY_PATH" = "x" ]; then
    echo "error: variable BASTION_SSH_PRIV_KEY_PATH is required...exiting!"
    exit 2;
fi

if [ ! -f $BASTION_SSH_PRIV_KEY_PATH ]; then
    echo "error: bastion private key file at path [$BASTION_SSH_PRIV_KEY_PATH] does not exist...exiting!"
    exit 2;
fi

if [ ! -f $SETENV_BASTION_PATH ]; then
    echo "error: file $SETENV_BASTION_PATH does not exist...Please make sure you ran the cloud management terraform project which should have created it...exiting!"
    exit 2;
fi

if [ -f $SETENV_BASTION_PATH ]; then
    . $SETENV_BASTION_PATH
fi

BASTION_LINUX_HOST=$BASTION_LINUX_HOST_1
BASTION_LINUX_HOST_USER=$BASTION_LINUX_HOST_1_USER

if [ "x$BASTION_LINUX_HOST" = "x" ]; then
    echo "error: variable BASTION_SSH_HOST does not exist and is required...exiting!"
    exit 2;
fi

if [ "x$BASTION_LINUX_HOST_USER" = "x" ]; then
    echo "error: variable BASTION_SSH_USER does not exist and is required...exiting!"
    exit 2;
fi

##rebuild project
/bin/sh build.sh $ENVTARGET

##sync built project
echo "Sending files to $BASTION_LINUX_HOST_USER@$BASTION_LINUX_HOST..."
rsync -arvz -e "ssh $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH" --delete $BUILD_DIR/ $BASTION_LINUX_HOST_USER@$BASTION_LINUX_HOST:~/$APPID

## execute the sync to management from the bastion
ssh $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH -A $BASTION_LINUX_HOST_USER@$BASTION_LINUX_HOST "/bin/bash ~/$APPID/sync-to-management.sh $APPID"