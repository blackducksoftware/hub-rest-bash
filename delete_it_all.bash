#!/bin/bash

# A script to delete all the projects from a Hub server

HUB_URL=$1
HUB_USERNAME=$2
HUB_PASSWORD=$3
LIMIT=$4

LIMIT=${LIMIT:-100}

source hub-rest-functions.bash

authenticate $1 $2 $3

# projects_json 1
delete_all_projects &
delete_all_codelocations &
wait