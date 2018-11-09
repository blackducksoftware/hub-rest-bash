#!/usr/bin/env bats

# To run these test you must have BATS (see https://github.com/sstephenson/bats)
#

# You also need to supply a running Hub server and user account 

load fixtures

function setup()
{
	cd $BATS_TEST_DIRNAME
	cd ..
	source hub-rest-functions.bash
	# authenticate ${HUB_SERVER_URL} ${HUB_USER} ${HUB_PASSWORD}
}

function authenticate_for_test() {
	>&2 authenticate ${HUB_SERVER_URL} ${HUB_USER} ${HUB_PASSWORD}
}
# TODO: Fix this test
# @test "authenticate returns failed authentication for a bad username/password" {
# 	result="$(authenticate ${HUB_SERVER_URL} badusername badpassword 2>&1)"
# 	[ "${status}" -eq 2 ]
# 	[ "${result}" == "Failed authentication" ]
# }

@test "api.html returns 200" {
	authenticate_for_test
	result="$(curl -s -I -k ${HUB_SERVER_URL}/api.html | grep 200)"
	[ ! -z "${result}" ]
}
