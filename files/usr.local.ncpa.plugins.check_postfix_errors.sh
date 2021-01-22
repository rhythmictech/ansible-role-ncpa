#!/bin/bash

# exit codes
e_ok=0
e_warning=1
e_critical=2
e_unknown=3


usage="Invalid command line usage"

if [ -z $1 ]; then
    echo $usage
    exit $e_unknown
fi

while getopts ":t:w:c:" options
do
    case $options in
	t ) total=$OPTARG ;;
        w ) warning=$OPTARG ;;
        c ) critical=$OPTARG ;;
        * ) echo $usage
            exit $e_unknown ;;
    esac
done

# determine error size
errorSize=$(tail -n $total /var/log/maillog |  grep ' 550 ' | wc -l)
if [ -z $errorSize ]
then
    exit $e_unknown
fi

if [ $errorSize -ge $critical ]; then
    echo -n "CRIT: "
    retval=$e_critical
elif [ $errorSize -ge $warning ]; then
    echo -n "WARN: "
    retval=$e_warning
elif [ $errorSize -lt $warning ]; then
    echo -n "OK: "
    retval=$e_ok
fi

echo "$errorSize errors found in maillogs | error_count=$errorSize | error_total=$total"
exit $retval
