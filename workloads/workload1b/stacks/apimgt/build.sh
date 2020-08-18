#!/usr/bin/env bash

set -e

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
THISDIRNAME=`basename $THISDIR`
BASEDIR="$THISDIR/../../../.."
RELATIVE_PATH=`echo $THISDIR | rev | cut -d"/" -f1-3  | rev`
RELATIVE_PATH_CLEAN=`echo "$RELATIVE_PATH" | sed -e 's/[\/]/_/g'`

## load common vars
. $BASEDIR/common/scripts/build_common.sh

## load workload common
. $THISDIR/../../workloadenv.sh

## Env Arg
ENVTARGET="$1"

## stackname prefix to use as a unique file prefix within the global ansible solution
## to avoid issues, must be a name without spaces or special characters
STACKNAME="${WORKLOAD_NAME}apimgt"

## build ansible artifacts
build_ansible $THISDIR $BASEDIR $STACKNAME $ENVTARGET

## build cce artifacts
build_cce $THISDIR $BASEDIR $STACKNAME $ENVTARGET