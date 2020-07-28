# webmethods api management stack

An ansible project for to provison a webmethods api management stack in cluster-mode

## Some sysprep tasks

On the ansible management server, run the sysprep playbook first:

```bash
ansible-playbook -i inventory sagenv-sysprep-all.yaml
```

## Api Gateway Stack

First, run the "set-secrets" playbook to specify the passwords you'll want to apply with the components:

```bash
ansible-playbook -i inventory $(stackid)_provision_full_apigateway_setsecrets.yaml
```

Then, Run the following playbook to provision API gateway nodes and related components (Terracotta, Elastic Search) 

```bash
ansible-playbook -i inventory $(stackid)_provision_full_apigateway.yaml
```

Or use nohup (good idea to make sure the scripts continue to run even if you lose the connection to the server)

```bash
nohup ansible-playbook -i inventory $(stackid)_provision_full_apigateway.yaml  &> $HOME/nohup-full_apigateway.out &
```

## Api Portal Stack

Note: You can run this playbook while the Api Gateway stack is running.

First, run the "set-secrets" playbook to specify the passwords you'll want to apply with the components:

```bash
ansible-playbook -i inventory $(stackid)_provision_full_apiportal_setsecrets.yaml
```

Then, make sure that the path variables defined in "$(stackid)_provision_full_apiportal.yaml" are present on the local ansible server (or update the file to specify the right paths)

- provision_installer_exec_filepath_local: "{{ cce_provisioning_content_localpath }}/installers/SoftwareAGInstaller20191216-LinuxX86.bin"
- provision_installer_image_filepath_local: "{{ cce_provisioning_content_localpath }}/images/products/softwareag_105_apiportal_linux_x64.zip"
- provision_installer_license_filepath_local: "{{ cce_provisioning_content_localpath }}/licenses/sag_licenses_105/webmethods/API Portal v10.5/0000489922_APIPortal101.xml"
- provision_installer_exec_filename: "SoftwareAGInstaller20191216-LinuxX86.bin"

Then, Run the following playbook to provision API Portal node

```bash
ansible-playbook -i inventory $(stackid)_provision_full_apiportal.yaml
```

Or use nohup (good idea to make sure the scripts continue to run even if you lose the connection to the server)

```bash
nohup ansible-playbook -i inventory $(stackid)_provision_full_apiportal.yaml  &> $HOME/nohup-full_apiportal.out &
```