# webmethods-infra-samples

Sample project that demonstrate infrastructure-as-code concepts with SoftwareAG webMethods.

Author: Fabien Sanglier (fabien.sanglier@softwareaggov.com)

For cloud provisioning of this project, please refer to the sister terraform project which will generate the cloud infrastructure for this.
See https://github.com/lanimall/webmethods-infra-samples-terraform for more details.

## Setup the submodules

```
git submodule add https://github.com/lanimall/webmethods-devops-cce.git common/webmethods-cce
git submodule add https://github.com/lanimall/webmethods-devops-ansible.git common/webmethods-ansible
git submodule update --init --recursive
```

## build

```
./build.sh
```