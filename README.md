# Nextcloud Deployment

> Numerous configs adapted from https://github.com/ReinerNippes/nextcloud

## Current Status
Requirements:
- Vagrant
- Ansible
- Packer
- Terraform
- AWS CLI credentials already in your environment

### Dev Environment
To spin up a dev environment, enter the `dev` directory and use `vagrant up`.

This will call vagrant to create a virtual machine, which will then call ansible to provision it with the necessary packages. Vagrant will then expose the webpage's port on [https://localhost:1235](https://localhost:1235).

### Test Environment
To spin up a test environment, enter the `test` directory, run `packer build build-test-environment.json`, then run `terraform init`, then run `terraform apply`.

This will call packer to create an AMI based on the ansible playbook in the default branch of your github repo and leave it in AWS. Terrform will then deploy the image to an instance and output the automatically generated IP address to access for testing.

Don't forget to `terraform destroy` if you don't want to incur charges for the test environment. You may also want to delete the AMI and snapshot created, although they don't cost very much to host.

### Prod Environment
To spin up a test environment, enter the `prod` directory, run `packer build build-prod-environment.json`, then run `terraform init`, then run `terraform apply`.

This will call packer to create an AMI based on the ansible playbook in the default branch of your github repo and leave it in AWS. Terrform will then deploy the image to an instance and associate a pre-existing elastic IP named `{{ project_name }}-prod`. It is up to you to have DNS setup to point your prod URL to that IP already.
