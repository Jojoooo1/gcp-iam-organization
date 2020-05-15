#!/bin/bash
set -e

# Base variables
PROJECT_PREFIX="tf-folder-admin"

# Dependencies
source ../../variables.sh
source ../../functions.sh

# Variables
SERVICES=("cloudresourcemanager.googleapis.com")
SERVICE_ACCOUNT_ROLES=("resourcemanager.folderAdmin")

#
## Project ##
# 1.1 Project: Create
PARENT_FOLDER_NAME="Admin"
PARENT_FOLDER_ID=$(gcloud alpha resource-manager folders list --folder $PARENT_FOLDER_NAME | grep $PARENT_FOLDER_NAME | awk '{print $3}')
createProject $PROJECT_NAME $PARENT_FOLDER_ID
# 1.2 Project: Link project to billing account
linkProjectToBillingAccount $PROJECT_NAME $ORGANIZATION_BILLING_ACCOUNT_ID
# 1.3 Project: Enable API
enableServices $PROJECT_NAME $SERVICES
#
## IAM ##
# 2.1 ServiceAccount: Create & download
SERVICE_ACCOUNT_DESCRIPTION="Terraform folder admin service account"
createServiceAccount $PROJECT_NAME $SERVICE_ACCOUNT_DESCRIPTION
DownloadServiceAccountKeys $PROJECT_NAME
grantRolesOnOrganization $PROJECT_NAME $ORGANIZATION_ID $SERVICE_ACCOUNT_ROLES
#
## Backend ##
# 3.1 Bucket: Create
createBucketForProject $PROJECT_NAME

tee info.txt <<EOF
PROJECT_NAME: $PROJECT_NAME
PROJECT_BUCKET_NAME: $PROJECT_BUCKET_NAME

SERVICE_ACCOUNT_NAME: $SERVICE_ACCOUNT_NAME
SERVICE_ACCOUNT_ID: $SERVICE_ACCOUNT_ID
SERVICE_ACCOUNT_KEY_PATH: $SERVICE_ACCOUNT_KEY_PATH
EOF
