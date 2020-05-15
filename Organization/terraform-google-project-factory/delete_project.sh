#!/bin/bash
set -e

# Base variables
PROJECT_PREFIX="tf-folder-factory"

# Dependencies
source ../../../scripts/variables.sh
source ../../../scripts/functions.sh

# prevent grep to exit on no match
PROJECT_DETAILS=$(gcloud projects list | grep $PROJECT_PREFIX || true)
[ -z "$PROJECT_DETAILS" ] && echo "Project with prefix '$PROJECT_PREFIX' not found" && exit 1
PROJECT_ID=$(echo $PROJECT_DETAILS | awk '{print $1}')
# TODO: multiple project found

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
