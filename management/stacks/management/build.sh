#!/usr/bin/env bash

set -e

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
THISDIRNAME=`basename $THISDIR`
BASEDIR="$THISDIR/../../.."

## load common vars
. $BASEDIR/common/scripts/build_common.sh

## load workload common
. $THISDIR/../../workloadenv.sh

## Env Arg
ENVTARGET="$1"

## stackname prefix to use as a unique file prefix within the global ansible solution
## to avoid issues, must be a name without spaces or special characters
STACKNAME="${WORKLOAD_NAME}mgtsetup"

## build ansible artifacts
build_ansible $THISDIR $BASEDIR $STACKNAME $ENVTARGET

## build cce artifacts
build_cce $THISDIR $BASEDIR $STACKNAME $ENVTARGET

## copy ansible vars 
## IMPORTANT: no transformation so the var file overwrites the default ( = do not proviude STACKID here)
# if [ -d $THIS_ANSIBLE/vars ]; then
#     if [ ! -d $BUILD_ANSIBLE/vars ]; then
#         mkdir -p $BUILD_ANSIBLE/vars
#     fi 
#     copyfiles $THIS_ANSIBLE/vars $BUILD_ANSIBLE/vars $STACKID "true" "false"
# fi