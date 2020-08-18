#!/usr/bin/env bash

set -e

RUNTARGET="$1"

## validate the values to be the expected ones
function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }
valid_args=("all" "internaldatastore" "terracotta" "apigateway" "apiportal" "update")
if [[ ! " ${valid_args[@]} " =~ " $RUNTARGET " ]]; then
    valid_values=$(join_by ' , ' ${valid_args[@]})
    echo "warning: provisioning target \"$RUNTARGET\" is not valid. Valid values are: $valid_values"
    exit 2;
fi
echo "Provisioning target \"$RUNTARGET\" is valid... will execute the right playbooks."

if [ "$RUNTARGET" = "fixupdates" ]; then
    nohup ansible-playbook -i inventory ./$(stackid)_fixupdates.yaml &> $HOME/nohup-$(stackid)_fixupdates.yaml.out &
    echo "provisionning $(stackid)_fixupdates in progress... check $HOME/nohup-$(stackid)_fixupdates.out for progress"
fi

if [ "$RUNTARGET" = "allserial" ]; then
    nohup ansible-playbook -i inventory ./$(stackid)_full.yaml &> $HOME/nohup-$(stackid)_full.out &
    echo "provisionning $(stackid)_full in progress... check $HOME/nohup-$(stackid)_full.out for progress"
fi

if [ "$RUNTARGET" = "all" ] || [ "$RUNTARGET" = "internaldatastore" ]; then
    nohup ansible-playbook -i inventory ./$(stackid)_internaldatastore.yaml &> $HOME/nohup-$(stackid)_internaldatastore.out &
    echo "$(stackid)_internaldatastore In progress... check $HOME/nohup-$(stackid)_internaldatastore.out for progress"
fi

#### TODO: these 2 should be serial...
if [ "$RUNTARGET" = "all" ] || [ "$RUNTARGET" = "terracotta" ]; then
    nohup ansible-playbook -i inventory ./$(stackid)_terracotta.yaml &> $HOME/nohup-$(stackid)_terracotta.out &
    echo "$(stackid)_terracotta In progress... check $HOME/nohup-$(stackid)_terracotta.out for progress"
fi

if [ "$RUNTARGET" = "all" ] || [ "$RUNTARGET" = "apigateway" ]; then
    nohup ansible-playbook -i inventory ./$(stackid)_apigateway.yaml &> $HOME/nohup-$(stackid)_apigateway.out &
    echo "$(stackid)_apigateway In progress... check $HOME/nohup-$(stackid)_apigateway.out for progress"
fi

if [ "$RUNTARGET" = "all" ] || [ "$RUNTARGET" = "apiportal" ]; then
    nohup ansible-playbook -i inventory ./$(stackid)_apiportal.yaml &> $HOME/nohup-$(stackid)_apiportal.out &
    echo "$(stackid)_apiportal In progress... check $HOME/nohup-$(stackid)_apiportal.out for progress"
fi

echo "All installation/configuration in progress..."