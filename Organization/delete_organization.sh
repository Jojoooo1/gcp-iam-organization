#!/bin/bash
set -e

# gcloud User should have role "Folder Admin"
ORGANIZATION_NAME="cloud-computing-jonathan"

# Gets organization ID
ORGANIZATION_ID=$(gcloud organizations list | grep $ORGANIZATION_NAME | awk '{print $2}')

# Delete admin folder
ADMIN_FOLDER_ID=$(gcloud alpha resource-manager folders list --organization $ORGANIZATION_ID | grep "Admin" | awk '{print $3}')
gcloud alpha resource-manager folders delete $ADMIN_FOLDER_ID
# Delete Engineering folder
# ENGINEERING_FOLDER_ID=$(gcloud alpha resource-manager folders list --organization $ORGANIZATION_ID | grep "Engineering" | awk '{print $3}')
# for child in "Dev" "Staging" "Prod"; do
#   FOLDER_ID=$(gcloud alpha resource-manager folders list --folder $ENGINEERING_FOLDER_ID | grep $child | awk '{print $3}')
#   gcloud alpha resource-manager folders delete $FOLDER_ID
# done
# gcloud alpha resource-manager folders delete $ENGINEERING_FOLDER_ID
