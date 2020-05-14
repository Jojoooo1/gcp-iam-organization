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
  PROJECT_PREFIX=$1
  PROJECT_DETAILS=$(gcloud projects list | grep $PROJECT_PREFIX)
  return $PROJECT_DETAILS
}
createProject() {
  PROJECT=$1
  gcloud projects create $PROJECT
}
createProjectWithinFolder() {
  PROJECT=$1
  FOLDER=$2
  gcloud projects create $PROJECT \
    --folder $FOLDER
}
linkProjectToBillingAccount() {
  PROJECT=$1
  BILLING_ACCOUNT=$2
  gcloud beta billing projects link $PROJECT \
    --billing-account $BILLING_ACCOUNT
}
enableServices() {
  PROJECT=$1
  SERVICES=$2
  for i in ${!SERVICES[@]}; do # @ get all value of the array ${} exec the value ! represent the index
    gcloud services enable ${SERVICES[$i]} --project $PROJECT
  done
}
createServiceAccount() {
  PROJECT=$1
  SERVICE_ACCOUNT=$2
  DESCRIPTION=$3
  gcloud iam service-accounts create $SERVICE_ACCOUNT \
    --display-name $DESCRIPTION \
    --project $PROJECT
}
DownloadServiceAccountKeys() {
  SA_ID=$1
  KEY_PATH=$3
  gcloud iam service-accounts keys create $KEY_PATH \
    --iam-account=$SA_ID
}
grantRolesOnProject() {
  SA_ID=$1
  ROLES=$3
  for i in ${!ROLES[@]}; do # @ get all value of the array ${} exec the value ! represent the index
    echo "Granting role '${ROLES[$i]}' to '$SA_ID' on Project '$PROJECT'"
    gcloud projects add-iam-policy-binding $PROJECT \
      --member serviceAccount:$SA_ID \
      --role ${ROLES[$i]}
  done
}
grantRolesOnOrganization() {
  SA_ID=$1
  ORG_ID=$2
  ROLES=$3
  for i in ${!ROLES[@]}; do # @ get all value of the array ${} exec the value ! represent the index
    echo "Granting role '${ROLES[$i]}' to '$SA_ID' on Organization '$ORG_ID'"
    gcloud organizations add-iam-policy-binding $ORG_ID \
      --member serviceAccount:$SA_ID \
      --role ${ROLES[$i]}
  done
}
grantResourceManagerOnFolder() {
  SA_ID=$1
  FOLDER=$2
  gcloud resource-manager folders add-iam-policy-binding $FOLDER \
    --member serviceAccount:$SA_ID \
    --role roles/resourcemanager.folderViewer
}

deleteProject() {
  PROJECT_PREFIX=$1

  PROJECT_DETAILS=$(gcloud projects list | grep $PROJECT_PREFIX)
  PROJECT_ID=$(echo $PROJECT_DETAILS | awk '{print $1}')

  echo $PROJECT_ID

  [ -z "$PROJECT_ID" ] && echo "Project with prefix '$PROJECT_PREFIX' not found" && return 1

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
}
