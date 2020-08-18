#!/usr/bin/env bash

set -e

THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR"

COMMON_DIR="$BASEDIR/common"
COMMON_ANSIBLE="$COMMON_DIR/webmethods-ansible/"
COMMON_SAGCCE="$COMMON_DIR/webmethods-cce/"

BUILD_DIR="$BASEDIR/build"
BUILD_COMMON_ANSIBLE="$BUILD_DIR/webmethods-ansible/"
BUILD_COMMON_CCE="$BUILD_DIR/webmethods-cce/"

## load common vars
. $BASEDIR/common/scripts/build_common.sh

## Args
ENVTARGET="$1"
APP_NAME="$2"

## validate the env values and exit if invalid
validate_args_env $ENVTARGET

## create build directory if does not exist
if [ ! -d $BUILD_DIR ]; then
    mkdir -p $BUILD_DIR
fi

## First, cleanup + assemble build template
if [ -d $BUILD_DIR ]; then
    rm -Rf $BUILD_DIR/*
fi

## Copy the common libraries
rsync -arvz --exclude static_* --delete $COMMON_ANSIBLE $BUILD_COMMON_ANSIBLE
rsync -arvz --exclude static_* --delete $COMMON_SAGCCE $BUILD_COMMON_CCE

### copy the sync-to-management script on the bastion
if [ -f $THISDIR/sync-to-management.sh ]; then
    cp $THISDIR/sync-to-management.sh $BUILD_DIR/
fi

### then build management projects
/bin/bash $BASEDIR/management/build.sh "$@"

### build the workloads
for f in $THISDIR/workloads/*; do
    if [ -d "$f" ]; then
        if [ -f $f/build.sh ]; then
            /bin/bash $f/build.sh "$@"
        fi
    fi
done