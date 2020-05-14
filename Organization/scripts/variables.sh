#!/bin/bash
set -e

# TODO: to finish
[[ ! -x "$(command -v gcloud)" ]] && echo "gcloud not found. Exiting." && exit 1
[[ ! -x "$(command -v gsutil)" ]] && echo "gsutil not found. Exiting." && exit 1

# Mandatory variable set in project
# ENV="dev"
# PROJECT_PREFIX="terraform-project-factory"

# BILLING_NAME: optional

[ -z "$ENV" ] && echo "DEV needs to bet set. Exiting." && exit 1
[ -z "$PROJECT_PREFIX" ] && echo "PROJECT_PREFIX needs to bet set. Exiting." && exit 1
[ -z "$PARENT_FOLDER_NAME" ] && echo "PARENT_FOLDER_NAME needs to bet set. Exiting." && exit 1

# Organization
ORGANIZATION_NAME="cloud-computing-jonathan"
ORGANIZATION_ID=$(gcloud organizations list | grep $ORGANIZATION_NAME | awk '{print $2}')
[[ $ORGANIZATION_ID == "" ]] && echo "The organization id provided does not exist. Exiting." && exit 1
# Hierarchy
ENGINEERING_FOLDER_ID=$(gcloud alpha resource-manager folders list --organization $ORGANIZATION_ID | grep "Engineering" | awk '{print $3}')
ENV_FOLDER_ID=$(gcloud alpha resource-manager folders list --folder $ENGINEERING_FOLDER_ID | grep "$(tr '[:lower:]' '[:upper:]' <<<${ENV:0:1})${ENV:1}" | awk '{print $3}') # Gets folder based on env
# Billing
[[ -z $BILLING_NAME ]] && BILLING_NAME=testing
BILLING_ID=$(gcloud alpha billing accounts list | grep $BILLING_NAME | awk '{print $1}')
[[ $BILLING_ID == "" ]] && echo "The Billing id provided does not exist. Exiting." && exit

# Project pre-defined variable
PROJECT_RANDOM_ID=$RANDOM
PROJECT_NAME="$ENV-$PROJECT_PREFIX-$PROJECT_RANDOM_ID"
#
PROJECT_SERVICE_ACCOUNT_NAME="$PROJECT_NAME-sa"
PROJECT_SERVICE_ACCOUNT_ID="serviceAccount:$PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com"
PROJECT_BUCKET_NAME="$PROJECT_NAME-backend"
PROJECT_KEY_PATH="./keys/$PROJECT_NAME-sa-keyfile.json"
