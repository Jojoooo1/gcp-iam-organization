#!/bin/bash
set -e

# Base variables
PROJECT_PREFIX="tf-project-factory"

# Dependencies
source ../../variables.sh
source ../../functions.sh

# Variables
SERVICES=("cloudresourcemanager.googleapis.com" "cloudbilling.googleapis.com" "iam.googleapis.com" "admin.googleapis.com" "appengine.googleapis.com")
# billingbudgets.googleapis.com: only required if configuring budgets for projects.
SA_ORGANIZATION_ROLES=("resourcemanager.organizationViewer" "roles/resourcemanager.projectCreator" "roles/billing.user" "roles/compute.xpnAdmin" "roles/compute.networkAdmin" "roles/iam.serviceAccountAdmin")
SA_PROJECT_ROLES=("roles/resourcemanager.projectIamAdmin")

#
## Project ##
# 1.1 Project: Create project within folder
TF_PROJECT_FACTORY_FOLDER_ID=$(gcloud alpha resource-manager folders list --folder $ENGINEERING_FOLDER_ID | grep "Terraform" | awk '{print $3}')
createProject $PROJECT_NAME $TF_PROJECT_FACTORY_FOLDER_ID
# 1.2 Project: Link project to billing account
linkProjectToBillingAccount $PROJECT_NAME $PRIMARY_BILLING_ACCOUNT_ID
# 1.3 Project: Enable API
enableServices $PROJECT_NAME $SERVICES
#
## IAM ##
# 2.1 ServiceAccount: Create
createServiceAccount $PROJECT_SERVICE_ACCOUNT_ID "Terraform project factory service account"
# 2.2 ServiceAccount: Download keys
DownloadServiceAccountKeys $PROJECT_SERVICE_ACCOUNT_ID $PROJECT_KEY_PATH
# 2.3 ServiceAccount: Grant permissions on organization
grantRolesOnOrganization $ORGANIZATION_ID $PROJECT_SERVICE_ACCOUNT_ID $SA_ORGANIZATION_ROLES
# 2.4 ServiceAccount: Grant permissions on project
grantRolesOnProject $PROJECT_NAME $PROJECT_SERVICE_ACCOUNT_ID $SA_PROJECT_ROLES
# 2.5 ServiceAccount: Grant permissions on folder
grantRolesOnFolder $TF_PROJECT_FACTORY_FOLDER_ID $PROJECT_SERVICE_ACCOUNT_ID

# tee info.txt <<EOF
# PROJECT_NAME: $PROJECT_NAME
# PROJECT_SERVICE_ACCOUNT_NAME: $PROJECT_SERVICE_ACCOUNT_NAME
# PROJECT_SERVICE_ACCOUNT_FULL_NAME: $PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com
# CREDENTIALS_KEY_NAME: $PROJECT_NAME-keyfile.json
# PROJECT_BUCKET_NAME: $PROJECT_BUCKET_NAME
# EOF
