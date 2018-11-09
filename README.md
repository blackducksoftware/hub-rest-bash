## Overview ##
The hub-rest-bash is a collection of bash shell functions/scripts for interacting with a Hub server through the Hub's REST API

Status: *In Development*

## To Use ##
```bash
source hub-rest-functions.bash
print_projects.bash https://your-hub-hostname sysadmin the-password | jq .
```

where the `jq` command/utility is used to make the json output pretty

## Documentation ##

See the wiki: https://github.com/blackducksoftware/hub-rest-bash/wiki
