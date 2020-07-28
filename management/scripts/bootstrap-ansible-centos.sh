#!/usr/bin/env bash

set -e

#### ansible
sudo yum install -y epel-release
sudo yum install -y ansible
ansible localhost -m ping