#!/bin/bash

#
#
# User and User group functions
#
# Expected to be sourced by hub-rest-functions.bash
#
# Assumes that HUB_COOKIE_FILE and AUTH_OUTPUT are already set
#
# Copyright 2018 - Black Duck Software
# Author: Glenn Snyder
#

source common.bash

function users_json()
{
	OPTIONS="$1"

	get_with_options /api/users ${OPTIONS}
}

function current_user_json()
{
	${CURL_CMD} -X GET "${HUB_URL}/api/current-user"
}

function user_groups_json()
{	
	OPTIONS="$1"
	
	get_with_options /api/usergroups ${OPTIONS}
}

function delete_all_users()
{
	delete_all_of_something users_json users
}

function delete_all_user_groups()
{
	delete_all_of_something user_groups_json user-groups
}