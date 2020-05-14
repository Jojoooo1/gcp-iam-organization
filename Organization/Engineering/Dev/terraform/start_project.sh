#!/bin/bash
set -e

if [[ ! -x "$(command -v gcloud)" ]]; then
  echo "gcloud not found"
  exit 1
fi

if [[ ! -x "$(command -v gsutil)" ]]; then
  echo "gsutil not found"
  exit 1
fi

ENV="dev"
PROJECT_PREFIX="terraform-k8s"

# TODO: Case multiple project exist (gcloud projects list | grep $PROJECT_NAME_START | wc -l)

# Organization
ORGANIZATION_NAME="cloud-computing-jonathan"
ORGANIZATION_ID=$(gcloud organizations list | grep $ORGANIZATION_NAME | awk '{print $2}')
ENGINEERING_FOLDER_ID=$(gcloud alpha resource-manager folders list --organization $ORGANIZATION_ID | grep "Engineering" | awk '{print $3}')
# Folder
FOLDER_ID=$(gcloud alpha resource-manager folders list --folder $ENGINEERING_FOLDER_ID | grep "$(tr '[:lower:]' '[:upper:]' <<<${ENV:0:1})${ENV:1}" | awk '{print $3}')
BILLING_ID=$(gcloud alpha billing accounts list | grep "testing" | awk '{print $1}')
# Project
PROJECT_RANDOM_ID=$RANDOM
PROJECT_NAME="$ENV-$PROJECT_PREFIX-$PROJECT_RANDOM_ID"
#
PROJECT_SERVICE_ACCOUNT_NAME="$PROJECT_NAME-sa"
PROJECT_BUCKET_NAME="$PROJECT_NAME-backend"
PROJECT_KEY_PATH="./keys/$PROJECT_NAME-sa-keyfile.json"

## PROJECT : Engineering / dev / project ##
# 1.1 Project: Create project within Dev folder
gcloud projects create $PROJECT_NAME \
  --folder $FOLDER_ID
# 1.2 Project: Link project to billing account
gcloud beta billing projects link $PROJECT_NAME \
  --billing-account $BILLING_ID

# 1.3 Project: Enable API
gcloud services enable compute.googleapis.com --project $PROJECT_NAME
gcloud services enable container.googleapis.com --project $PROJECT_NAME
gcloud services enable cloudresourcemanager.googleapis.com --project $PROJECT_NAME # Creates, reads, and updates metadata for Google Cloud Platform resource containers.

## IAM ##
# 2.1 ServiceAccount: Create
gcloud iam service-accounts create $PROJECT_SERVICE_ACCOUNT_NAME \
  --display-name "Terraform admin service account" \
  --project $PROJECT_NAME
# 2.2 ServiceAccount: Download keys
gcloud iam service-accounts keys create $PROJECT_KEY_PATH \
  --iam-account=$PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com \
  --project $PROJECT_NAME
#
# 2.3 ServiceAccount: Grant permissions
#
# Kubernetes Engine Admin: Provides access to full management of clusters and their Kubernetes API objects
# lowest: project
gcloud projects add-iam-policy-binding $PROJECT_NAME \
  --member serviceAccount:$PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com \
  --role roles/container.admin # roles/container.clusterAdmin # Kubernetes Engine Cluster Admin: Provides access to management of clusters.

# Compute Admin: Full control of all Compute Engine resources
# lowest: Disk, image, instance, instanceTemplate, nodeGroup, nodeTemplate, snapshot Beta
# Warning: by default assign role/editor to project through Compute Engine default service account
gcloud projects add-iam-policy-binding $PROJECT_NAME \
  --member serviceAccount:$PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com \
  --role roles/compute.admin # If the user will be managing virtual machine instances that are configured to run as a service account, you must also grant the roles/iam.serviceAccountUser role.

# Service Account User: Run operations as the service account
# lowest: ServiceAccount
gcloud projects add-iam-policy-binding $PROJECT_NAME \
  --member serviceAccount:$PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser # (comput needs it to start VM, disk etc.)

# Service Account Admin: Create and manage service account
# lowest: ServiceAccount
gcloud projects add-iam-policy-binding $PROJECT_NAME \
  --member serviceAccount:$PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountAdmin

# Project IAM Admin: Provides permissions to administer Cloud IAM policies on projects
# lowest: project
gcloud projects add-iam-policy-binding $PROJECT_NAME \
  --member serviceAccount:$PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectIamAdmin # required in gke module if service_account is set to create
# gcloud iam service-accounts add-iam-policy-binding $PROJECT_SERVICE_ACCOUNT_NAME --member serviceAccount:$PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com \
#   --role roles/resourcemanager.projectCreator # Project Creator: Provides access to create new projects. Once a user creates a project, they're automatically granted the owner role for that project.

## BACKEND ##
# 3.1 RemoteBackend (tf state): Create & Enable versioning for state recovery in case of accident
gsutil mb -p $PROJECT_NAME -l us-east1 gs://$PROJECT_BUCKET_NAME && gsutil versioning set on gs://$PROJECT_BUCKET_NAME
# 3.2 RemoteBackend (tf state): Grant ServiceAccount permission to write to created bucket
gsutil iam ch serviceAccount:$PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com:legacyBucketWriter gs://$PROJECT_BUCKET_NAME

echo "PROJECT_NAME: $PROJECT_NAME"
echo "PROJECT_SERVICE_ACCOUNT_NAME: $PROJECT_SERVICE_ACCOUNT_NAME"
echo "PROJECT_SERVICE_ACCOUNT_FULL_NAME: $PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com"
echo "CREDENTIALS_KEY_NAME: $PROJECT_NAME-keyfile.json"
echo "PROJECT_BUCKET_NAME: $PROJECT_BUCKET_NAME"

tee info.txt <<EOF
PROJECT_NAME: $PROJECT_NAME
PROJECT_SERVICE_ACCOUNT_NAME: $PROJECT_SERVICE_ACCOUNT_NAME
PROJECT_SERVICE_ACCOUNT_FULL_NAME: $PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com
CREDENTIALS_KEY_NAME: $PROJECT_NAME-keyfile.json
PROJECT_BUCKET_NAME: $PROJECT_BUCKET_NAME
EOF

#
#
#
#
# gcloud iam service-accounts add-iam-policy-binding $PROJECT_SERVICE_ACCOUNT_NAME --member serviceAccount:$PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com \
#   --role roles/resourcemanager.projectCreator # Project Creator: Provides access to create new projects. Once a user creates a project, they're automatically granted the owner role for that project.

# Test if IAM is setup correctly
# gcloud auth activate-service-account --key-file=./keys/dev-tf-sa-16296-keyfile.json
# gcloud container clusters create test-cluster --num-nodes 1 --region us-east1 --project dev-tf-project-16296
# yes | gcloud container clusters delete test-cluster --region us-east1 --project dev-tf-project-16296
