#!/usr/bin/env bash

set -e

THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/../.."

BUILD_DIR="$BASEDIR/build"
SCRIPTS_DIR="$THISDIR/scripts"

##create build directory if does not exist
if [ ! -d $BUILD_DIR ]; then
    mkdir -p $BUILD_DIR
fi

### copy various helper scripts
if [ -d $SCRIPTS_DIR ]; then
    if [ ! -d $BUILD_DIR/scripts ]; then
        mkdir -p $BUILD_DIR/scripts
    fi
    rsync -arvz --delete $SCRIPTS_DIR/bootstrap-* $BUILD_DIR/scripts/

    if [ -f $SCRIPTS_DIR/sync-to-management.sh ]; then
        cp $SCRIPTS_DIR/sync-to-management.sh $BUILD_DIR/
    fi
fi

### build the sub stacks
for f in $THISDIR/stacks/*; do
    if [ -d "$f" ]; then
        if [ -f $f/build.sh ]; then
            /bin/bash $f/build.sh "$@"
        fi
    fi
done


### build the sub apps
for f in $THISDIR/apps/*; do
    if [ -d "$f" ]; then
        if [ -f $f/build.sh ]; then
            /bin/bash $f/build.sh "$@"
        fi
    fi
done