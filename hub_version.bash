#!/bin/bash

HUB_URL=$1

source hub-rest-functions.bash

authenticate ${HUB_URL}

hub_version