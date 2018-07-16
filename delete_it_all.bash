#!/bin/bash

##
# hub-rest-bash
#
# Copyright (C) 2018 Black Duck Software, Inc.
# http://www.blackducksoftware.com/
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements. See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership. The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
##

# A script to delete all the projects and scans (aka code locations)from a Hub server

HUB_URL=$1
HUB_USERNAME=$2
HUB_PASSWORD=$3
LIMIT=$4

LIMIT=${LIMIT:-100}

source hub-rest-functions.bash

authenticate $1 $2 $3

echo "Uncomment the following 2 lines if you really want to delete everything. You've been warned!"
delete_all_projects &
delete_all_codelocations &
wait