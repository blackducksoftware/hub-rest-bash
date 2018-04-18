#!/bin/bash

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

