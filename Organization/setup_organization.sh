#!/bin/bash
set -e

# gcloud User should have role "Folder Admin"
ORGANIZATION_NAME="cloud-computing-jonathan"

# Gets organization ID
ORGANIZATION_ID=$(gcloud organizations list | grep $ORGANIZATION_NAME | awk '{print $2}')

# Create child Engineering from organization
gcloud alpha resource-manager folders create \
  --display-name="Engineering" \
  --organization=$ORGANIZATION_ID

ENGINEERING_FOLDER_ID=$(gcloud alpha resource-manager folders list --organization $ORGANIZATION_ID | grep "Engineering" | awk '{print $3}')

# Creates Dev folder from Engineering
gcloud alpha resource-manager folders create \
  --display-name="Terraform project factory" \
  --folder=$ENGINEERING_FOLDER_ID
TF_ADMIN_PROJECT_FACTORY_FOLDER_ID=$(gcloud alpha resource-manager folders list --folder $ENGINEERING_FOLDER_ID | grep "Terraform project factory" | awk '{print $3}')

# Creates Dev folder from Engineering
gcloud alpha resource-manager folders create \
  --display-name="Dev" \
  --folder=$ENGINEERING_FOLDER_ID
DEV_FOLDER_ID=$(gcloud alpha resource-manager folders list --folder $ENGINEERING_FOLDER_ID | grep "Dev" | awk '{print $3}')

# Creates Staging folder from Engineering
gcloud alpha resource-manager folders create \
  --display-name="Staging" \
  --folder=$ENGINEERING_FOLDER_ID
STAGING_FOLDER_ID=$(gcloud alpha resource-manager folders list --folder $ENGINEERING_FOLDER_ID | grep "Staging" | awk '{print $3}')

# Creates Prod folder from Engineering
gcloud alpha resource-manager folders create \
  --display-name="Prod" \
  --folder=$ENGINEERING_FOLDER_ID
PROD_FOLDER_ID=$(gcloud alpha resource-manager folders list --folder $ENGINEERING_FOLDER_ID | grep "Prod" | awk '{print $3}')

echo "DEV_FOLDER_ID: $DEV_FOLDER_ID"
echo "STAGING_FOLDER_ID: $STAGING_FOLDER_ID"
echo "PROD_FOLDER_ID: $PROD_FOLDER_ID"
