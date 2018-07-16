#!/bin/bash

HUB_URL=$1
HUB_USERNAME=$2
HUB_PASSWORD=$3
PROJECT_NAME=$4

source hub-rest-functions.bash

authenticate $1 $2 $3

create_project ${PROJECT_NAME}
