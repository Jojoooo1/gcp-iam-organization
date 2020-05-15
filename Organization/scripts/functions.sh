#!/bin/bash
set -e

# TODO: to finish
if [[ ! -x "$(command -v gcloud)" ]]; then
  echo "gcloud not found"
  exit 1
fi

if [[ ! -x "$(command -v gsutil)" ]]; then
  echo "gsutil not found"
  exit 1
fi

getProjectDetails() {
  # PROJECT_PREFIX=$1
  PROJECT_DETAILS=$(gcloud projects list | grep $1)
  return $PROJECT_DETAILS
}
createProject() {
  # PROJECT_NAME=$1
  gcloud projects create $1
}
createProjectWithinFolder() {
  # PROJECT_NAME=$1
  # FOLDER=$2
  gcloud projects create $1 \
    --folder $2
}
linkProjectToBillingAccount() {
  # PROJECT_NAME=$1
  # ORGANIZATION_BILLING_ACCOUNT_ID=$2
  gcloud beta billing projects link $1 \
    --billing-account $2
}
enableServices() {
  # PROJECT_NAME=$1
  SERVICES=$2
  for i in ${!SERVICES[@]}; do # @ get all value of the array ${} exec the value ! represent the index
    gcloud services enable ${SERVICES[$i]} --project $1
  done
}
createServiceAccount() {
  # PROJECT_NAME=$1
  # DESCRIPTION=$2
  gcloud iam service-accounts create "$1-sa" \
    --display-name $2 \
    --project $1
}
DownloadServiceAccountKeys() {
  # PROJECT_NAME=$1
  gcloud iam service-accounts keys create "./keys/$1-sa-keyfile.json" \
    --iam-account "serviceAccount:$1-sa@$1.iam.gserviceaccount.com"
}
grantRolesOnProject() {
  # PROJECT_NAME=$1
  ROLES=$2
  for i in ${!ROLES[@]}; do # @ get all value of the array ${} exec the value ! represent the index
    echo "Granting role '${ROLES[$i]}' to 'serviceAccount:$1-sa@$1.iam.gserviceaccount.com' on Project '$1'"
    gcloud projects add-iam-policy-binding $1 \
      --member "serviceAccount:$1-sa@$1.iam.gserviceaccount.com" \
      --role ${ROLES[$i]}
  done
}
grantRolesOnOrganization() {
  # PROJECT_NAME=$1
  # ORG_ID=$2
  ROLES=$3
  for i in ${!ROLES[@]}; do # @ get all value of the array ${} exec the value ! represent the index
    echo "Granting role '${ROLES[$i]}' to 'serviceAccount:$1-sa@$1.iam.gserviceaccount.com' on Organization '$1'"
    gcloud organizations add-iam-policy-binding $2 \
      --member "serviceAccount:$1-sa@$1.iam.gserviceaccount.com" \
      --role ${ROLES[$i]}
  done
}
grantRolesOnFolder() {
  # PROJECT_NAME=$1
  # FOLDER_ID=$2
  gcloud resource-manager folders add-iam-policy-binding $2 \
    --member "serviceAccount:$1-sa@$1.iam.gserviceaccount.com" \
    --role roles/resourcemanager.folderViewer
}

deleteProject() {
  # PROJECT_PREFIX=$1

  PROJECT_DETAILS_TO_DELETE=$(gcloud projects list | grep $1)
  PROJECT_ID_TO_DELETE=$(echo $PROJECT_DETAILS_TO_DELETE | awk '{print $1}')

  echo $PROJECT_ID_TO_DELETE

  [ -z "$PROJECT_ID_TO_DELETE" ] && echo "Project with prefix '$1' not found" && return 1

  read -r -p "Are you sure you want to delete the project '$PROJECT_ID_TO_DELETE' [Y/n]:  " RESPONSE
  echo
  if [[ $RESPONSE =~ ^([yY][eE][sS]|[yY])$ ]]; then

    gcloud projects delete $PROJECT_ID_TO_DELETE
    rm -f keys/*

  else

    echo
    echo "Action cancelled exiting..."
    exit 0

  fi
}

createBucketForProject() {
  # PROJECT_NAME=$1
  # RemoteBackend (tf state): Create & Enable versioning for state recovery in case of accident
  gsutil mb -p $1 -l us-east1 "gs://$1-backend" && gsutil versioning set on "gs://$1-backend"
  # RemoteBackend (tf state): Grant ServiceAccount permission to write to created bucket
  gsutil iam ch "serviceAccount:$1-sa@$1.iam.gserviceaccount.com:legacyBucketWriter" "gs://$1-backend"

}
