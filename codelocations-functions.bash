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
#
#
# Codelocatons functions
#
# Expected to be sourced by hub-rest-functions.bash
#
# Assumes that HUB_COOKIE_FILE and AUTH_OUTPUT are already set
#
# Copyright 2018 - Black Duck Software
# Author: Glenn Snyder
#

source common.bash

function codelocations_json()
{
	OPTIONS="$1"

	get_with_options /api/codelocations ${OPTIONS}	
}

function delete_all_codelocations()
{
	delete_all_of_something codelocations_json codelocations
}

