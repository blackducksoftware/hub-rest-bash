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
# Project functions
#
# Expected to be sourced by hub-rest-functions.bash
#
# Assumes that HUB_COOKIE_FILE and AUTH_OUTPUT are already set
#
#

source common.bash

function projects_json()
{
	OPTIONS="$1"

	get_with_options /api/projects ${OPTIONS}	
}

function delete_all_projects()
{
	delete_all_of_something projects_json projects
}

function get_assigned_user_groups()
{
	PROJECT_ID="$1"
	OPTIONS="$2"

	get_with_options /api/projects/${PROJECT_ID}/usergroups ${OPTIONS}
}

function project_versions_json()
{
	project_id=$1
	OPTIONS="$2"

	get_with_options /api/projects/${project_id}/versions
}

function project_version_risk_profile_json()
{
	project_id=$1
	version_id=$2
	OPTIONS="$3"

	get_with_options /api/projects/${project_id}/versions/${version_id}/risk-profile
}

function assign_user_group_to_project()
{
	PROJECT_NAME="$1"
	GROUP_NAME="$2"

	PROJECT_ID=$(get_id_of_something_from_name projects_json ${PROJECT_NAME})

	GROUP_ID=$(get_id_of_something_from_name user_groups_json ${GROUP_NAME} "q=${GROUP_NAME}")
	GROUP_URL=$(get_url_of_something_from_name user_groups_json ${GROUP_NAME} "q=${GROUP_NAME}")

	POST_ARGS=(-d "{\"group\": \"${GROUP_URL}\"}" --header 'Content-Type: application/vnd.blackducksoftware.user-group-assignment-1+json' --header 'Accept: */*')

	if [ "$(hub_major_version ${HUB_VERSION})" == "3" ]; then
		path="/api/v1/projects/${PROJECT_ID}/teamgroups/${GROUP_ID}"
	else
		path="/api/projects/${PROJECT_ID}/usergroups"
	fi
	post ${path}
	echo "Assigned user group ${GROUP_NAME} to project ${PROJECT_NAME}"
}

# http://ec2-18-216-152-91.us-east-2.compute.amazonaws.com:8080/api/v1/projects/c0777b6e-b61a-4da6-8456-3b1f821d180f/teamgroups/ef72e36c-592c-4227-bca3-520a3a07df43

function assign_user_groups_to_multiple_projects()
{
	PROJECT_NAME_PREFIX="$1"
	GROUP_NAME_PREFIX="$2"

	echo "Assigning all user groups with prefix=${GROUP_NAME_PREFIX} to all projects with prefix=${PROJECT_NAME_PREFIX}"
	projects_json "q=name:${PROJECT_NAME_PREFIX}" |
	jq -r '.items | .[].name' |
	while read project_name
	do
		user_groups_json "q=${GROUP_NAME_PREFIX}" |
		jq -r '.items | .[].name' |
		while read group_name
		do
			assign_user_group_to_project ${project_name} ${group_name}
		done
	done
}