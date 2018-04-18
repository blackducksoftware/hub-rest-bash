#!/bin/bash

#
# This script demonstrates assigning user groups to project (groups)
#
# It assumes that the user groups and projects groups follow a naming convention
# where the prefix of the user groups and project groups is known, e.g. healthcare
#
# It uses a library of bash functions which are sourced into the current shell, see below
#
# To demo this you need to setup some projects and user groups, 
# 	optionally add some users into those groups and give roles to the groups, as follows:
#		1. Projects
#			* healthcare-project1
#			* healthcare-project2
#			* pos-project1
#			* pos-project2
#			* inventory-project1
#			* inventory-project2
#		2. User groups
#			* healthcare-developers
#			* healthcare-bom-managers
#			* pos-developers
#			* pos-bom-managers
#			* inventory-developers
#			* inventory-bom-managers
#
# Copyright 2018 - Black Duck Software
# Author: Glenn Snyder
#
HUB_URL=$1
HUB_USERNAME=${2:-sysadmin}
HUB_PASSWORD=${3:-blackduck}

source hub-rest-functions.bash

authenticate $HUB_URL $HUB_USERNAME $HUB_PASSWORD

# Assign all user groups whose name starts with 'healthcare' to all projects whose name starts with 'healthcare'
assign_user_groups_to_multiple_projects healthcare healthcare
# Assign all user groups whose name starts with 'pos' to all projects whose name starts with 'pos'
assign_user_groups_to_multiple_projects pos pos
# Assign all user groups whose name starts with 'inventory' to all projects whose name starts with 'inventory'
assign_user_groups_to_multiple_projects inventory inventory
