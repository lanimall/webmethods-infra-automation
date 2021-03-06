#!/usr/bin/env bash

set -e

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
THISDIRNAME=`basename $THISDIR`
BASEDIR="$THISDIR/../../.."

## load common vars
. $BASEDIR/common/scripts/build_common.sh

## load workload common
. $THISDIR/../../workloadenv.sh

## stackname prefix to use as a unique file prefix within the global ansible solution
## to avoid issues, must be a name without spaces or special characters
STACKNAME="${WORKLOAD_NAME}cce"

## Env Arg
ENVTARGET="$1"

## build ansible artifacts
build_ansible $THISDIR $BASEDIR $STACKNAME $ENVTARGET

## build cce artifacts
build_cce $THISDIR $BASEDIR $STACKNAME $ENVTARGET