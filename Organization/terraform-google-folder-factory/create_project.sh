#!/bin/bash
set -e

# Base variables
PROJECT_PREFIX="tf-folder-admin"

# Dependencies
source ../utils/variables.sh
source ../utils/functions.sh

# Variables
SERVICES=("cloudresourcemanager.googleapis.com")
SERVICE_ACCOUNT_ROLES=("resourcemanager.folderAdmin")

#
## Project ##
echo ">>>>>>> Creating project"
PARENT_FOLDER_NAME="Admin"
PARENT_FOLDER_ID=$(gcloud alpha resource-manager folders list --organization $ORGANIZATION_ID | grep $PARENT_FOLDER_NAME | awk '{print $3}')
createProject $PROJECT_NAME $PARENT_FOLDER_ID
echo ">>>>>>> Linking billing account to project"
linkProjectToBillingAccount $PROJECT_NAME $ORGANIZATION_BILLING_ACCOUNT_ID
echo ">>>>>>> Enabling API"
enableServices $PROJECT_NAME $SERVICES
#
## IAM ##
echo ">>>>>>> Creating service account"
SERVICE_ACCOUNT_DESCRIPTION="Terraform folder admin service account"
createServiceAccount $PROJECT_NAME $SERVICE_ACCOUNT_DESCRIPTION
echo ">>>>>>> downloading service account key"
DownloadServiceAccountKeys $PROJECT_NAME
echo ">>>>>>> Grating role on organization"
grantRolesOnOrganization $PROJECT_NAME $ORGANIZATION_ID $SERVICE_ACCOUNT_ROLES
#
## Backend ##
echo ">>>>>>> Creating bucket"
createBucketForProject $PROJECT_NAME

tee info.txt <<EOF
PROJECT_NAME: $PROJECT_NAME
PROJECT_BUCKET_NAME: $PROJECT_BUCKET_NAME

SERVICE_ACCOUNT_NAME: $SERVICE_ACCOUNT_NAME
SERVICE_ACCOUNT_ID: $SERVICE_ACCOUNT_ID
SERVICE_ACCOUNT_KEY_PATH: $SERVICE_ACCOUNT_KEY_PATH
EOF
