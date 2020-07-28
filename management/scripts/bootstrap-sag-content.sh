#!/usr/bin/env bash

set -e

THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`

if [ -f $HOME/setenv_sagcontent_bucket.sh ]; then
    . $HOME/setenv_sagcontent_bucket.sh
fi

##depending on the size, ideally that path should be a mount point to a larger disk
if [ "x$BASE_LOCAL_DIR" = "x" ]; then
    echo "error: variable BASE_LOCAL_DIR is required...exiting!"
    echo "Make sure you created a file at $HOME/setenv_sagcontent_bucket.sh that sets and export the variable SAG_CONTENT_BUCKET_NAME...as follows:"
    echo "echo 'export BASE_LOCAL_DIR=\"/opt/softwareag/webmethods-devops-sagcontent\"' >> $HOME/setenv_sagcontent_bucket.sh"
    exit 2;
fi

if [ "x$SAG_CONTENT_BUCKET_NAME" = "x" ]; then
    echo "error: variable SAG_CONTENT_BUCKET_NAME is required...exiting!"
    echo "Make sure you created a file at $HOME/setenv_sagcontent_bucket.sh that sets and export the variable SAG_CONTENT_BUCKET_NAME...as follows:"
    echo "echo 'export SAG_CONTENT_BUCKET_NAME=\"SOME_NAME\"' >> $HOME/setenv_sagcontent_bucket.sh"
    exit 2;
fi

if [ "x$SAG_CONTENT_BUCKET_BASEPATH" = "x" ]; then
    echo "error: variable SAG_CONTENT_BUCKET_BASEPATH is required...exiting!"
    echo "Make sure you created a file at $HOME/setenv_sagcontent_bucket.sh that sets and export the variable SAG_CONTENT_BUCKET_BASEPATH...as follows:"
    echo "echo 'export SAG_CONTENT_BUCKET_BASEPATH=\"SOME_PATH_IN_THE_BUCKET\"' >> $HOME/setenv_sagcontent_bucket.sh"
    exit 2;
fi

AWS_S3_OP="$1"
AWS_S3_SOURCE_SUBPATH="$2"
LOCAL_TARGET_SUBPATH="$3"

if [ "x$AWS_S3_OP" = "x" ]; then
    echo "error: runtime attribute for AWS_S3_OP is required...exiting!"
    echo "format: $THIS <AWS_S3_OP> <AWS_S3_SOURCE_SUBPATH> <LOCAL_TARGET_SUBPATH>"
    exit 2;
fi

if [ "x$AWS_S3_SOURCE_SUBPATH" = "x" ]; then
    echo "error: runtime attribute for AWS_S3_SOURCE_SUBPATH is required...exiting!"
    echo "format: $THIS <AWS_S3_OP> <AWS_S3_SOURCE_SUBPATH> <LOCAL_TARGET_SUBPATH>"
    exit 2;
fi

if [ "x$LOCAL_TARGET_SUBPATH" = "x" ]; then
    echo "error: runtime attribute for LOCAL_TARGET_SUBPATH is required...exiting!"
    echo "format: $THIS <AWS_S3_OP> <AWS_S3_SOURCE_SUBPATH> <LOCAL_TARGET_SUBPATH>"
    exit 2;
fi

LOCAL_DIR=$BASE_LOCAL_DIR/$LOCAL_TARGET_SUBPATH
BUCKET_URI="s3://$SAG_CONTENT_BUCKET_NAME/$SAG_CONTENT_BUCKET_BASEPATH/$AWS_S3_SOURCE_SUBPATH"
LOCAL_DIR_OWNER=`id -nu`

##create folder
if [ ! -d $LOCAL_DIR ]; then
    sudo mkdir -p $LOCAL_DIR
fi
sudo chown -Rf $LOCAL_DIR_OWNER:$LOCAL_DIR_OWNER $LOCAL_DIR

## making sure to load the awscli python env
if [ -f $HOME/setenv_awscli.sh ]; then
    . $HOME/setenv_awscli.sh
fi

# Synchronize the keys from the bucket.

if [ "$AWS_S3_OP" = "sync" ]; then
    AWS_S3_ARGS="--delete"
fi
echo "About to run the command: aws s3 $AWS_S3_OP $AWS_S3_ARGS $BUCKET_URI $LOCAL_DIR"

aws s3 $AWS_S3_OP $AWS_S3_ARGS $BUCKET_URI $LOCAL_DIR

echo "Content was downloaded in $LOCAL_DIR..."