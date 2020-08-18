#!/usr/bin/env bash

set -e

RUNTARGET="$1"

## validate the values to be the expected ones
function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }
valid_args=("fixupdates" "alldatabase" "allserial" "allparallel" "integrationserver" "um")
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

if [ "$RUNTARGET" = "alldatabase" ]; then
    nohup ansible-playbook -i inventory ./$(stackid)_full-db.yaml &> $HOME/nohup-$(stackid)_full-db.out &
    echo "$(stackid)_full-db.yaml In progress... check $HOME/nohup-$(stackid)_full-db.out for progress"
fi

if [ "$RUNTARGET" = "allserial" ]; then
    nohup ansible-playbook -i inventory ./$(stackid)_full.yaml &> $HOME/nohup-$(stackid)_full.out &
    echo "provisionning $(stackid)_full in progress... check $HOME/nohup-$(stackid)_full.out for progress"
fi

#### TODO: these 2 should be serial...
if [ "$RUNTARGET" = "allparallel" ] || [ "$RUNTARGET" = "integrationserver" ]; then
    nohup ansible-playbook -i inventory ./$(stackid)_iscore.yaml &> $HOME/nohup-$(stackid)_iscore.out &
    echo "$(stackid)_iscore.yaml In progress... check $HOME/nohup-$(stackid)_iscore.out for progress"
fi

if [ "$RUNTARGET" = "allparallel" ] || [ "$RUNTARGET" = "um" ]; then
    nohup ansible-playbook -i inventory ./$(stackid)_universalmessaging.yaml &> $HOME/nohup-$(stackid)_universalmessaging.out &
    echo "$(stackid)_universalmessaging.yaml In progress... check $HOME/nohup-$(stackid)_universalmessaging.out for progress"
fi

echo "All installation/configuration in progress..."