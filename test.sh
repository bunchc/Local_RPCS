#!/bin/bash

jsonlint -q openstack.json > /dev/null
LOL=$?

if [ ${LOL} -eq 0 ]; then
	echo "JSON Valid"
else
	echo "Fix the JSON"
	exit $?
fi

vagrant pristine -f
