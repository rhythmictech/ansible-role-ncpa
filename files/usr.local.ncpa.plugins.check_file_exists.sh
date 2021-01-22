#! /bin/sh

PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`

. $PROGPATH/utils.sh


if [ ! "$#" == 1 ] ; then
  echo "Usage: $PROGNAME <FILE_NAME>"
  exit $STATE_CRITICAL
fi

if [ -f $1 ] ; then
  echo "OK - ${1} exists"
  exit $STATE_OK
fi

echo "CRITICAL - ${1} does not exist"
exit $STATE_CRITICAL
