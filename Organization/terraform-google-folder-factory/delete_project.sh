#!/bin/bash
set -e

# Base variables
ENV="dev"
PROJECT_PREFIX="tf-folder-admin"

# prevent grep to exit on no match && if permission denied object probably does not exist
PROJECT_DETAILS=$(gcloud projects list | grep $PROJECT_PREFIX || true)
[ -z "$PROJECT_DETAILS" ] && echo "Project with prefix '$PROJECT_PREFIX' not found" && exit 1
PROJECT_NAME=$(echo $PROJECT_DETAILS | awk '{print $1}')
SERVICE_ACCOUNT=$(gcloud iam service-accounts describe $PROJECT_NAME-sa@$PROJECT_NAME.iam.gserviceaccount.com) # will exit if not found

read -r -p "Are you sure you want to delete the project '$PROJECT_NAME' and serviceAccount '$PROJECT_NAME-sa' [Y/n]:  " RESPONSE
echo
if [[ $RESPONSE =~ ^([yY][eE][sS]|[yY])$ ]]; then

  gcloud iam service-accounts delete "$PROJECT_NAME-sa@$PROJECT_NAME.iam.gserviceaccount.com"
  gcloud projects delete $PROJECT_NAME
  rm -f keys/*

else

  echo
  echo "Action cancelled exiting..."
  exit 0

fi
