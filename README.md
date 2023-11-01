# Codefresh Infra

This is a personal project using pulumi to manage aws infrastructure. Also installing the Classic and Gitops Hybrid Runtimes. I am using JavaScript as the programming language of choice.

## Features

### aws

This directory is for managing AWS infrastructure.  Mainly creating a VPC, EKS Cluster, and aditional items to make those work. Purpose is to create items easily for testing. Also to destroy all items when no longer needed for easier cleanup.

### classic-runtime

Using pulumi to install the Classic Runtime via helm.  Not dependant on AWS but whatever is set as the current context in my kube config file.

### gitops-runtime

Using pulumi to install the Gitopes Runtime via helm.  Not dependant on AWS but whatever is set as the current context in my kube config file.  Also needs the cfv2 cli installed and configured to complete the instalaltion.

## How To Use

You will need to have the following installed and configured.

- aws cli
- kubernetes cli
- codefrehsh v2 cli

To deploy you need to do the following

1. Navigate to the directory
1. Run `npm install`
1. Run `pulumi up` to deploy
