#!/bin/bash
set -e

if [[ ! -x "$(command -v gcloud)" ]]; then
  echo "gcloud not found"
  exit 1
fi

if [[ ! -x "$(command -v gsutil)" ]]; then
  echo "gsutil not found"
  exit 1
fi

# Loads dependencies
. variables.sh
. ../../../functions.sh

gcloud projects add-iam-policy-binding $PROJECT_NAME \
  --member serviceAccount:$PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com \
  --role roles/compute.admin # Compute Admin: Full control of all Compute Engine resources.
gcloud projects add-iam-policy-binding $PROJECT_NAME \
  --member serviceAccount:$PROJECT_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser # When granted alongside compute.admin => grants access to create VMs, attach disks to, and update metadata on VM instances that can run as a service account.
