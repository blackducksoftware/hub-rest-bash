#!/bin/bash

#
# Script to gather scan statistics (min, max, average) for Hub scans
#
# Copyright 2017 - Black Duck Software
# Author: Glenn Snyder
#
HUB_URL=$1
HUB_USERNAME=$2
HUB_PASSWORD=$3

source hub-rest-functions.bash

authenticate $HUB_URL $HUB_USERNAME $HUB_PASSWORD

incomplete_scans_str="$(incomplete_scans)"
while [[ "${incomplete_scans_str}" != "All complete" ]]
do
	echo "waiting for scans to complete"
	echo ${incomplete_scans_str}
	sleep 120
	incomplete_scans_str=$(incomplete_scans)
done
scan_stats