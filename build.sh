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

##create build directory if does not exist
if [ ! -d $BUILD_DIR ]; then
    mkdir -p $BUILD_DIR
fi

##First, cleanup + assemble build template
if [ -d $BUILD_DIR ]; then
    rm -Rf $BUILD_DIR/*
fi

rsync -arvz --exclude static_* --delete $COMMON_ANSIBLE $BUILD_COMMON_ANSIBLE
rsync -arvz --exclude static_* --delete $COMMON_SAGCCE $BUILD_COMMON_CCE

### copy the sync-to-management script on the bastion
if [ -f $THISDIR/sync-to-management.sh ]; then
    cp $THISDIR/sync-to-management.sh $BUILD_DIR/
fi

## then build projects
/bin/bash $BASEDIR/management/build.sh "$@"
/bin/bash $BASEDIR/workloads/fed_data_backbone/build.sh "$@"