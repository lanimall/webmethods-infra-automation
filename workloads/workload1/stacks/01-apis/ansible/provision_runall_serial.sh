#!/usr/bin/env bash

set -e

nohup ansible-playbook -i inventory ./$(stackid)_runall_serial.yaml &> $HOME/nohup-$(stackid).out &
echo "provisionning $(stackid) in progress... check $HOME/nohup-$(stackid).out for progress"