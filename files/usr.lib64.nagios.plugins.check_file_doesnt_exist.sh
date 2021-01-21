#! /bin/sh


if [ -f $1 ] ; then
	echo "CRITICAL - ${1} exists"
	exit 2
else
	echo "OK - ${1} does not exist"
	exit $STATE_OK
fi
