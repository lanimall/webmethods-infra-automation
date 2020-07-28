#!/usr/bin/env bash

THIS_ANSIBLE_DIRNAME="ansible"
THIS_CCE_DIRNAME="cce"
THIS_SCRIPTS_DIRNAME="scripts"

COMMON_DIRNAME="common"
COMMON_ANSIBLE_DIRNAME="webmethods-ansible"
COMMON_SAGCCE_DIRNAME="webmethods-cce"

BUILD_DIRNAME="build"
BUILD_ANSIBLE_DIRNAME=$COMMON_ANSIBLE_DIRNAME
BUILD_CCE_DIRNAME=$COMMON_SAGCCE_DIRNAME

## stack token for replacement
REPLACE_TOKEN_STACKNAME='$(stackname)'
REPLACE_TOKEN_ENV='$(stackenv)'
REPLACE_TOKEN_ID='$(stackid)'

FILE_PREFIX_SEPARATOR_TOKEN="_"

function build_token_value { 
    local tokenname=$1;
    local envname=$2;
    echo "$envname$tokenname"
}

function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }

function build_ansible { 
    local thisdir=$1;
    local basedir=$2;
    local stackname=$3;
    local envtarget=$4;
    
    ## validate the env values and exit if invalid
    validate_args_env $envtarget

    ### current dir vars
    BUILD_DIR="$basedir/$BUILD_DIRNAME"
    THIS_ANSIBLE=$thisdir/$THIS_ANSIBLE_DIRNAME
    BUILD_ANSIBLE="$BUILD_DIR/$BUILD_ANSIBLE_DIRNAME"

    ## copy ansible vars
    if [ -d $THIS_ANSIBLE/vars ]; then
        if [ ! -d $BUILD_ANSIBLE/vars ]; then
            mkdir -p $BUILD_ANSIBLE/vars
        fi 
        copyfiles $THIS_ANSIBLE/vars $BUILD_ANSIBLE/vars $stackname $envtarget "true" "true"
    fi

    ##copy ansible playbooks
    if [ -d $THIS_ANSIBLE ]; then
        if [ ! -d $BUILD_ANSIBLE ]; then
            mkdir -p $BUILD_ANSIBLE
        fi
        copyfiles $THIS_ANSIBLE $BUILD_ANSIBLE $stackname $envtarget "true" "true"
    fi

    ##copy ansible inventories for the right environment level
    if [ -d $THIS_ANSIBLE/inventory ]; then
        if [ ! -d $BUILD_ANSIBLE/inventory ]; then
            mkdir -p $BUILD_ANSIBLE/inventory
        fi 
        
        ##copy + replace tokens in the inventory file
        copyfiles $THIS_ANSIBLE/inventory $BUILD_ANSIBLE/inventory $stackname $envtarget "true" "false" "^.*[_]$envtarget[_].*$"
    fi
}

function build_cce { 
    local thisdir=$1;
    local basedir=$2;
    local stackname=$3;
    local envtarget=$4;
    
    ## validate the env values and exit if invalid
    validate_args_env $envtarget

    ### dir vars
    BUILD_DIR="$basedir/$BUILD_DIRNAME"
    THIS_CCE=$thisdir/$THIS_CCE_DIRNAME
    BUILD_CCE="$BUILD_DIR/$BUILD_CCE_DIRNAME"

    ## build stack id
    STACKID=$(build_token_value $stackname $envtarget)

    ##copy webmethods CCE content
    if [ -d $THIS_CCE/environments ]; then
        if [ ! -d $BUILD_CCE/environments ]; then
            mkdir -p $BUILD_CCE/environments
        fi 
        copyfiles $THIS_CCE/environments $BUILD_CCE/environments $stackname $envtarget "true" "true"
    fi

    ##copy webmethods templates
    if [ -d $THIS_CCE/templates ]; then
        if [ ! -d $BUILD_CCE/templates/$STACKID ]; then
            mkdir -p $BUILD_CCE/templates/$STACKID
        fi 
        cp -r $THIS_CCE/templates/* $BUILD_CCE/templates/$STACKID/
    fi
}

function copyfiles { 
    local sourcedir=$1;
    local targetdir=$2;
    local stackname=$3;
    local envtarget=$4;
    local do_replace_in_files=$5;
    local do_prefix_files=$6;
    local filename_regex_filter=$7;
    
    ## validate the env values and exit if invalid
    validate_args_env $envtarget

    ## build stack id
    fileprefix=$(build_token_value $stackname $envtarget)
    
    ## build the sed replacement
    local sedreplace="s/$REPLACE_TOKEN_ID/$fileprefix/g;s/$REPLACE_TOKEN_ENV/$envtarget/g;s/$REPLACE_TOKEN_STACKNAME/$stackname/g"; 
  
    if [ "x" == "x$filename_regex_filter" ]; then
        filename_regex_filter=".*"
    fi

    if [ "x" == "x$do_replace_in_files" ]; then
        do_replace_in_files="true"
    fi
    
    if [ "x" == "x$do_prefix_files" ]; then
        do_prefix_files="true"
    fi
    ### iterate over the files in the directory
    #cmd="find \"$sourcedir\" -type f ( ! -iname ".DS_Store" ) -regex \"$filename_regex_filter\" -maxdepth 1"
    local filelist=`find "$sourcedir" -type f \( ! -iname ".DS_Store" \) -regex "$filename_regex_filter" -maxdepth 1`
    for filepath in $filelist; do
        filename=`basename $filepath`
        if [ "true" == "$do_replace_in_files" ]; then
            if [ "true" == "$do_prefix_files" ]; then
                echo "Copying $filepath with file prefix + file content tokens replacement"
                
                sed $sedreplace $filepath > $targetdir/$fileprefix$FILE_PREFIX_SEPARATOR_TOKEN$filename
            else
                echo "Copying $filepath with file content tokens replacement only (no file prefix)"
                sed $sedreplace $filepath > $targetdir/$filename
            fi
        else
            if [ "true" == "$do_prefix_files" ]; then
                echo "Copying $filepath with file prefix only (no file content tokens replacement)"
                cp $filepath $targetdir/$fileprefix$FILE_PREFIX_SEPARATOR_TOKEN$filename
            else
                echo "Copying $filepath to target (no prefix / replace)"
                cp $filepath $targetdir/$filename
            fi
        fi
    done
}

function validate_args_env { 
    local envtarget=$1;

    valid_args=("prod" "dev")
    if [[ ! " ${valid_args[@]} " =~ " $envtarget " ]]; then
        valid_values=$(join_by ' , ' ${valid_args[@]})
        echo "warning: target \"$envtarget\" is not valid. Valid values are: $valid_values"
        exit 2;
    fi
    echo "Provisioning target \"$envtarget\" is valid."
}

