#!/bin/bash
set -e

ENV="dev"

# Organization
ORGANIZATION_NAME="cloud-computing-jonathan"
ORGANIZATION_ID=$(gcloud organizations list | grep $ORGANIZATION_NAME | awk '{print $2}')
ENGINEERING_FOLDER_ID=$(gcloud alpha resource-manager folders list --organization $ORGANIZATION_ID | grep "Engineering" | awk '{print $3}')
# Folder
FOLDER_ID=$(gcloud alpha resource-manager folders list --folder $ENGINEERING_FOLDER_ID | grep "$(tr '[:lower:]' '[:upper:]' <<<${ENV:0:1})${ENV:1}" | awk '{print $3}')
BILLING_ID=$(gcloud alpha billing accounts list | grep "testing" | awk '{print $1}')
# Project
PROJECT_RANDOM_ID=$RANDOM
PROJECT_NAME="$ENV-terraform-k8s-$PROJECT_RANDOM_ID"
#
PROJECT_SERVICE_ACCOUNT_NAME="$PROJECT_NAME-sa"
PROJECT_BUCKET_NAME="$PROJECT_NAME-backend"
PROJECT_KEY_PATH="./keys/$PROJECT_NAME-sa-keyfile.json"
