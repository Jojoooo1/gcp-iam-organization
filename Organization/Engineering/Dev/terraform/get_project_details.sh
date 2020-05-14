#!/bin/bash
set -e

if [[ ! -x "$(command -v gcloud)" ]]; then
  echo "gcloud not found"
  exit 1
fi

ENV="dev"
PROJECT_PREFIX="terraform-k8s"
#
PROJECT_DETAILS=$(gcloud projects list | grep $PROJECT_PREFIX)
#
PROJECT_ID=$(echo $PROJECT_DETAILS | awk '{print $1}')
PROJECT_NAME=$(echo $PROJECT_DETAILS | awk '{print $2}')
PROJECT_NUMBER=$(echo $PROJECT_DETAILS | awk '{print $3}')
PROJECT_RANDOM_ID=${PROJECT_ID##*project-}
#
PROJECT_SERVICE_ACCOUNT_NAME="$ENV-tf-sa-$PROJECT_RANDOM_ID"
BUCKET_NAME="$PROJECT_NAME-backend"

echo "PROJECT_ID: $PROJECT_ID"
echo "PROJECT_NAME: $PROJECT_NAME"
echo "PROJECT_NUMBER: $PROJECT_NUMBER"
echo "PROJECT_SERVICE_ACCOUNT_NAME: $PROJECT_SERVICE_ACCOUNT_NAME"
echo "BUCKET_NAME: $BUCKET_NAME"
