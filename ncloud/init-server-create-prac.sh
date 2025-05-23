#!/bin/bash

dnf -y update

# terraform download
TERRAFORM_VERSION="1.11.4"

curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip

unzip terraform.zip
mv -f terraform /usr/local/bin/
rm -f terraform.zip

hash -r
sleep 60

# terraform worker folder
mkdir terraform-infra
cd ./terraform-infra

# local variable create
export NCLOUD_ACCESS_KEY="access-key"
export NCLOUD_SECRET_KEY="secret-key"
export NCLOUD_REGION="KR"
export NCLOUD_SUPPORT_VPC=true
export TF_VAR_my_ip="$(curl -s ifconfig.me)/32"

# .tf download
curl -LO https://raw.githubusercontent.com/UHeeJoon/terraform-practice/main/ncloud/raw/server-create-prac-raw.tf

# apply
terraform init -upgrade
terraform apply -auto-approve
