#!/bin/bash
set -e

if [[ ! -x "$(command -v gcloud)" ]]; then
  echo "gcloud not found"
  exit 1
fi

ENV="dev"
PROJECT_NAME_START="$ENV-tf-project"
#
PROJECT_DETAILS=$(gcloud projects list | grep $PROJECT_NAME_START)
#
PROJECT_ID=$(echo $PROJECT_DETAILS | awk '{print $1}')
PROJECT_NAME=$(echo $PROJECT_DETAILS | awk '{print $2}')
PROJECT_NUMBER=$(echo $PROJECT_DETAILS | awk '{print $3}')
PROJECT_RANDOM_ID=${PROJECT_ID##*project-}
#
PROJECT_SERVICE_ACCOUNT_NAME="$ENV-tf-sa-$PROJECT_RANDOM_ID"
BUCKET_NAME="$PROJECT_NAME-backend"

## UPDATE ##
# gcloud projects get-iam-policy $PROJECT_NAME
# Service to update
gcloud services enable compute.googleapis.com --project $PROJECT_NAME
# iam policy to update
gcloud projects add-iam-policy-binding $PROJECT_NAME \
  --member serviceAccount:$PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com \
  --role roles/container.admin # Kubernetes Engine Admin: Provides access to full management of clusters and their Kubernetes API objects.
