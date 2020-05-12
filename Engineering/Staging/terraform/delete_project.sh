#!/bin/bash
set -e

if [[ ! -x "$(command -v gcloud)" ]]; then
  echo "gcloud not found"
  exit 1
fi

ENV="staging"
PROJECT_NAME_START="$ENV-tf-project"
#
PROJECT_DETAILS=$(gcloud projects list | grep $PROJECT_NAME_START)
#
PROJECT_ID=$(echo $PROJECT_DETAILS | awk '{print $1}')
#
read -r -p "Are you sure you want to delete the project \"$PROJECT_ID\" [Y/n]:  " RESPONSE
echo
if [[ $RESPONSE =~ ^([yY][eE][sS]|[yY])$ ]]; then

  gcloud projects delete $PROJECT_ID
  rm -f keys/*

else

  echo
  echo "Action cancelled exiting..."
  exit 0

fi
