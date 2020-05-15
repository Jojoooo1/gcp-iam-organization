#!/bin/bash
set -e

# TODO: to finish
[[ ! -x "$(command -v gcloud)" ]] && echo "gcloud not found. Exiting." && exit 1
[[ ! -x "$(command -v gsutil)" ]] && echo "gsutil not found. Exiting." && exit 1

# Mandatory
# PROJECT_PREFIX="tf-project-factory"
# Optional
# ENV="dev-"

# [ -z "$ENV" ] && echo "DEV needs to bet set. Exiting." && exit 1
[ -z "$PROJECT_PREFIX" ] && echo "PROJECT_PREFIX needs to bet set. Exiting." && exit 1

# Organization variables
ORGANIZATION_BILLING_ACCOUNT_ID="01612C-53F687-4F01A3"
ORGANIZATION_NAME="cloud-computing-jonathan"
ORGANIZATION_ID=$(gcloud organizations list | grep $ORGANIZATION_NAME | awk '{print $2}')
[[ $ORGANIZATION_ID == "" ]] && echo "The organization id provided does not exist. Exiting." && exit 1

# Hierarchy
# ENGINEERING_FOLDER_ID=$(gcloud alpha resource-manager folders list --organization $ORGANIZATION_ID | grep "Engineering" | awk '{print $3}')
# ENV_FOLDER_ID=$(gcloud alpha resource-manager folders list --folder $ENGINEERING_FOLDER_ID | grep "$(tr '[:lower:]' '[:upper:]' <<<${ENV:0:1})${ENV:1}" | awk '{print $3}') # Gets folder based on env

# Project pre-defined variable
RANDOM_ID=$RANDOM
PROJECT_NAME="$PROJECT_PREFIX-$RANDOM_ID"
# PROJECT_BUCKET_NAME="$PROJECT_NAME-backend"
# #
# SERVICE_ACCOUNT_NAME="$PROJECT_NAME-sa"
# SERVICE_ACCOUNT_ID="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com"
# SERVICE_ACCOUNT_KEY_PATH="./keys/$PROJECT_NAME-sa-keyfile.json"
