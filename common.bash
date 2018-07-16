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
# Determine the platform and adjust commands accordingly
#
platform='unknown'
unamestr=$(uname)
if [[ "${unamestr}" == 'Linux' ]]; then
	platform='linux'
elif [[ "${unamestr}" == 'Darwin' ]]; then
	platform='osx'
fi

datecmd='date'
if [[ "${platform}" == "osx" ]]; then
	datecmd='gdate'
fi

export CURL_CMD=$(which curl)
export JQ_CMD=$(which jq)
export BASENAME_CMD=$(which basename)
export CUT_CMD=$(which cut)

# Set/override, or extend GET_ARGS prior to calling the get_with_options function
declare -a GET_ARGS
GET_ARGS=( --header "Accept: application/json")

function get_with_options()
{
	PATH="$1"
	OPTIONS="$2"

	if [ "${OPTIONS}" == "" ]; then
		${CURL_CMD} "${CURL_ARGS[@]}" "${GET_ARGS[@]}" -X GET "${HUB_URL}${PATH}"
	else
		${CURL_CMD} "${CURL_ARGS[@]}" "${GET_ARGS[@]}" -X GET "${HUB_URL}${PATH}?${OPTIONS}"
	fi	
}

# Set POST_ARGS prior to calling the post function
declare -a POST_ARGS

function post()
{
	PATH="$1"

	${CURL_CMD} "${CURL_ARGS[@]}" "${POST_ARGS[@]}" "${HUB_URL}${PATH}"
}

export HUB_V_3="3"
export HUB_V_4="4"

function hub_version()
{
	# figure out the hub version
	response=$(get_with_options /api/current-version)
	version=$(echo ${response} | jq -r .version)
	error_msg=$(echo ${response} | jq -r .errorMessage)
	error_code=$(echo ${response} | jq -r .errorCode)

	if [ "$(echo ${error_msg} | grep -i 'not found')" != "" ]; then
		version=3
	fi
	export HUB_VERSION=${version}
}

function hub_major_version()
{
	version=$1

	echo ${version} | ${CUT_CMD} -c1 -
}

function get_id_of_something_from_name()
{
	FUNCTION_NAME=$1
	OBJECT_NAME=$2
	QUERY=${3:-q=name:${OBJECT_NAME}} # override this when the query doesn't conform to the syntax shown here

	echo $(${BASENAME_CMD} $(get_url_of_something_from_name ${FUNCTION_NAME} ${OBJECT_NAME} ${QUERY}))
}

function get_url_of_something_from_name()
{
	FUNCTION_NAME=$1
	OBJECT_NAME=$2
	QUERY=${3:-q=name:${OBJECT_NAME}} # override this when the query doesn't conform to the syntax shown here

	echo $(${FUNCTION_NAME} "${QUERY}" | ${JQ_CMD} -r '.items | .[0]._meta.href')
}

function delete_something_using_name()
{
	FUNCTION_NAME=$1
	OBJECT_NAME=$2

	url=$(get_url_of_something_from_name ${FUNCTION_NAME} ${OBJECT_NAME})
	delete_something_using_url ${url}
}

function delete_something_using_url()
{
	${CURL_CMD} "${CURL_ARGS[@]}" -X DELETE "$1"
}

export MAX_CONCURRENCY=8
function delete_all_of_something()
{
	# First argument is a function for GETting the objects, e.g. projects_json
	# Assumes that the JSON document being retrieved includes a "totalCount" element
	# and that the list of items resides in a "items" element
	# and that the specific item info resides in "_meta.href" for each item in the list
	FUNCTION_NAME=$1
	OBJECT_NAME=${2:-things}

	total_to_delete=None
	while true
	do
		response=$(${FUNCTION_NAME} limit=100)
		running=0
		if [ "${total_to_delete}" == "None" ]; then
			total_to_delete=$(echo ${response} | jq -r '.totalCount')
			echo "Deleting a total of ${total_to_delete} ${OBJECT_NAME}"
			remaining=${total_to_delete}
		else
			remaining=$(echo ${response} | jq -r '.totalCount')
		fi
		if [ "${remaining}" -gt 0 ]; then
			echo ${response} |
			${JQ_CMD} -r '.items | .[]._meta.href' |
			while read url
			do
				delete_something_using_url ${url} &
				running=$((running + 1))
				if [ ${running} -eq ${MAX_CONCURRENCY} ]; then
					wait
					running=0
				fi
			done
		else
			break
		fi
	done
	echo "Deleted ${total_to_delete} ${OBJECT_NAME}"
}