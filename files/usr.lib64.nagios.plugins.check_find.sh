#!/bin/bash

# Find wrapper that warns on file count matching an arbitrary find string

PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`

. $PROGPATH/utils.sh


if [ ! "$#" == 3 ] ; then
  echo "Usage: $PROGNAME <PATTERN> <WARN_AGE> <CRIT_AGE>"
  exit $STATE_CRITICAL
fi

PATTERN=$1
WARN=$2
CRIT=$3

CT=$(find $PATTERN|wc -l)

if [ $CT -gt $CRIT ] ; then
  echo "CRIT - $DIR has more than $CRIT files ($CT)"
  exit $STATE_CRITICAL
fi

if [ $CT -gt $WARN ] ; then
  echo "WARN - $DIR has more than $WARN files ($CT)"
  exit $STATE_WARN
fi

echo "OK - $DIR has $CT files"
exit $STATE_OK
