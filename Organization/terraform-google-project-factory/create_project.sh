#!/bin/bash
set -e

# Base variables
PROJECT_PREFIX="tf-project-admin"

# Dependencies
source ../utils/variables.sh
source ../utils/functions.sh

# Variables
SERVICES=("cloudresourcemanager.googleapis.com" "cloudbilling.googleapis.com" "iam.googleapis.com" "admin.googleapis.com" "appengine.googleapis.com")
SERVICE_ACCOUNT_ORGANIZATION_ROLES=("resourcemanager.organizationViewer" "resourcemanager.projectCreator" "billing.user" "compute.xpnAdmin" "compute.networkAdmin" "iam.serviceAccountAdmin")
SERVICE_ACCOUNT_PROJECT_ROLES=("resourcemanager.projectIamAdmin")

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

# Needs to wait for google actualizing account (takes a long time)
sleep 60

echo ">>>>>>> downloading service account key"
DownloadServiceAccountKeys $PROJECT_NAME

echo ">>>>>>> ServiceAccount: Granting role on organization"
grantRolesOnOrganization $PROJECT_NAME $ORGANIZATION_ID $SERVICE_ACCOUNT_ORGANIZATION_ROLES
echo ">>>>>>> ServiceAccount: Granting role on project"
grantRolesOnProject $PROJECT_NAME $ORGANIZATION_ID $SERVICE_ACCOUNT_PROJECT_ROLES
#
## Backend ##
echo ">>>>>>> Creating bucket"
createBucketForProject $PROJECT_NAME

echo
echo ">>>>>>> creating file info.txt"

tee info.txt <<EOF
PROJECT_NAME: $PROJECT_NAME
PROJECT_BUCKET_NAME: $PROJECT_NAME-backend

SERVICE_ACCOUNT_NAME: $PROJECT_NAME-sa
SERVICE_ACCOUNT_ID: $PROJECT_NAME-sa@$PROJECT_NAME.iam.gserviceaccount.com
SERVICE_ACCOUNT_KEY_PATH: $PROJECT_NAME-sa-keyfile.json
EOF
