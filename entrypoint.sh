#!/bin/bash

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform


# Install de aws cli
sudo yum -y update     
sudo yum -y install aws-cli 
aws --version   

export AWS_ACCESS_KEY_ID=AKIAXUPZYJA2CGTKMG7B
export AWS_SECRET_ACCESS_KEY=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
export AWS_DEFAULT_REGION=us-east-1
