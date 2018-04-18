#!/bin/bash

#
# A collection of functions to facilitate interaction with the Hub REST API server using curl and other tools
#
# Will work with Hub 3.7.x and Hub 4.x
#
# To use these functions source this script into your shell script, e.g.
#		source hub-rest.bash
#
# Then call the authenticate function to, well, authenticate and also setup the other functions to pass the
# correct cookie and header info with each subsequent request, e.g.
#		authenticate https://your-hub-dns-name hub-username hub-user-password
#
# Copyright 2017 - Black Duck Software
# Author: Glenn Snyder
#
export HUB_COOKIE_FILE=/tmp/hub-cookie-$$
export AUTH_OUTPUT=/tmp/auth-out-$$

#
# Modules
#
source project-functions.bash
source user-functions.bash
source codelocations-functions.bash

function pre-requisites()
{
	FULFILLED=true
	for tool in curl jq
	do
		if [ "$(which ${tool})" == "" ]; then
			FULFILLED=false
			echo "Must have ${tool} installed and somewhere on your PATH"
		fi
	done
	if [ "${FULFILLED}" == "false" ]; then
		echo "Install these tools and make sure they are on your PATH, exiting..."
		exit 1
	fi
}

declare -a CURL_ARGS

function set_curl_args()
{
	# Set the curl command to be used throughout the script, based on whether the hub server
	# is a v3.x versus v4.x server
	AUTH_OUTPUT_FILE=$1

	if [ "$(grep X-CSRF ${AUTH_OUTPUT_FILE})" == "" ]; then
		# for pre-4.x Hub systems there is no X-CSRF token generated
		# Using the insecure option (-k) since Hub is usually running a self-signed certificate
		CURL_ARGS=(-k -s -b ${HUB_COOKIE_FILE})
	else # v4.x
		# Need CSRF token for v4.x requests; search for token at beginning of line in auth output
		X_CSRF_TOKEN="$(cat ${AUTH_OUTPUT_FILE} | grep ^X-CSRF-TOKEN | awk '{print $2}' | tr -d '[:space:]')"
		# Using the insecure option (-k) since Hub is usually running a self-signed certificate
		CURL_ARGS=(-k -s -b ${HUB_COOKIE_FILE} --header "X-CSRF-TOKEN: ${X_CSRF_TOKEN}")
	fi
}

function authenticate()
{
	# Authenticate and save the cookie info for subsequent use
	export HUB_URL=$1
	HUB_USERNAME=${2:-sysadmin}
	HUB_PASSWORD=${3:-blackduck}

	if [ "${HUB_URL}" == "" ]; then
		echo "You must supply a HUB URL to authenticate against"
		exit 1
	fi
	# Using the insecure option (-k) since Hub is usually running a self-signed certificate
	curl -k -s -X POST --cookie-jar ${HUB_COOKIE_FILE} \
		--data "j_username=${HUB_USERNAME}&j_password=${HUB_PASSWORD}" \
		-i ${HUB_URL}/j_spring_security_check > ${AUTH_OUTPUT}

	set_curl_args ${AUTH_OUTPUT}
	if [ "$(grep 204 ${AUTH_OUTPUT})" ]; then
		echo "Successful authentication" 1>&2
	else
		echo "Failed authentication" 1>&2
		exit 2
	fi
	# Set the Hub version which is used by other functions to determine the right URL to use, e.g. v3.x vs v4.x of Hub
	hub_version
}

function code_locations_json()
{
	# the default limit value is 10, so we need to use a large number of our goal is to look across all code locations/scans
	${CURL_CMD} -X GET "${HUB_URL}/api/codelocations?limit=10000"
}

function code_location_scan_summaries_json()
{
	# For each code location there can be more than one scan summary
	code_locations_json | 
	jq -r '.items | .[]._meta.links | .[].href' |
	while read scan_summaries_url
	do
		${CURL_CMD} -X GET ${scan_summaries_url} | jq '.'
	done
}

function scan_times()
{
	# Generate the time, in seconds, for each scan (that has been marked 'COMPLETE')
	code_location_scan_summaries_json | 
	jq -r '.items | .[] | "\(.status) \(.createdAt) \(.updatedAt)"' |
	while read created_updated_at_str
	do
		status=$(echo ${created_updated_at_str} | awk '{print $1}')
		created_at_str=$(echo ${created_updated_at_str} | awk '{print $2}')
		updated_at_str=$(echo ${created_updated_at_str} | awk '{print $3}')
		created_at_ts=$(${datecmd} --utc --date=${created_at_str} +%s)
		updated_at_ts=$(${datecmd} --utc --date=${updated_at_str} +%s)
		if [[ "${status}" == "COMPLETE" ]]; then
			echo $(expr ${updated_at_ts} - ${created_at_ts})
		fi
	done
}

function incomplete_scans()
{
	# Locate, and count, the incomplete scans (i.e. those whose status != 'COMPLETE')
	incomplete_scan_count=0

	incomplete_scan_count=$(code_location_scan_summaries_json | 
	jq -r '.items | .[] | "\(.status) \(.createdAt) \(.updatedAt)"' |
	while read created_updated_at_str
	do
		status=$(echo ${created_updated_at_str} | awk '{print $1}')
		created_at_str=$(echo ${created_updated_at_str} | awk '{print $2}')
		updated_at_str=$(echo ${created_updated_at_str} | awk '{print $3}')
		created_at_ts=$(${datecmd} --utc --date=${created_at_str} +%s)
		updated_at_ts=$(${datecmd} --utc --date=${updated_at_str} +%s)
		if [[ "${status}" != "COMPLETE" ]]; then
			echo "incomplete"
		fi
	done |
	wc -l)

	if [[ ${incomplete_scan_count} -gt 0 ]]; then
		echo "There were ${incomplete_scan_count} scans not complete"
	else
		echo "All complete"
	fi
}

function scan_stats()
{
	# iterate over all the scans and accumulate the average, max, and min, i.e. the stats
	total_scan_time=0
	max_scan_time=0
	min_scan_time=-1
	num_scans=0

	for scan_time in $(scan_times)
	do
		if [[ "${scan_time}" -gt "${max_scan_time}" ]]; then
			max_scan_time=${scan_time}
		fi
		if [ "${scan_time}" -lt "${min_scan_time}" ] || [ "${min_scan_time}" -lt 0 ]; then
			min_scan_time=${scan_time}
		fi
		total_scan_time=$[total_scan_time +${scan_time}]
		num_scans=$[$num_scans +1]
	done
	echo -e "Average scan time: $(( ${total_scan_time}/${num_scans} )) over ${num_scans} scans\nMax scan time: ${max_scan_time}\nMin scan time: ${min_scan_time}"
}

pre-requisites

# authenticate $1
