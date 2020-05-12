#!/bin/bash
set -e

# TODO: to finish

createProjectWithinFolder() {
  gcloud projects create $1 \
    --folder $2
}
linkProjectToBillingAccount() {
  gcloud beta billing projects link $1 \
    --billing-account $2
}
enableServices() {
  PROJECT= $1
  SERVICES = $2
  for i in ${!SERVICES[@]}; do # @ get all value of the array ${} exec the value ! represent the index
    gcloud services enable ${SERVICES[$i]} --project $PROJECT
  done
}
enableRoles() {
  PROJECT= $1
  SERVICE_ACCOUNT = $2
  ROLES = $3
  for i in ${!ROLES[@]}; do # @ get all value of the array ${} exec the value ! represent the index
    gcloud projects add-iam-policy-binding $PROJECT \
      --member serviceAccount:$SERVICE_ACCOUNT@$PROJECT.iam.gserviceaccount.com \
      --role ${ROLES[$i]}
  done
}
