#!/usr/bin/env bash

HUB_URL=$1
HUB_USERNAME=$2
HUB_PASSWORD=$3
PROJECT_NAME=$4
PROJECT_VERSION=$5

source hub-rest-functions.bash

authenticate ${HUB_URL} ${HUB_USERNAME} ${HUB_PASSWORD}

PROJECT_ID=$(project_id_from_name ${PROJECT_NAME})
VERSION_ID=$(version_id_from_project ${PROJECT_ID} ${PROJECT_VERSION})

echo $(project_version_policy_status_json ${PROJECT_ID} ${VERSION_ID} | ${JQ_CMD} -r '.overallStatus')
