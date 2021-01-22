#!/bin/bash

if [[ $# -lt 3 ]]; then
        echo "Usage: check_lv.sh vg_name/lv_name warning% critical%"
        exit 2
fi

LVNAME=$1
WARN=$2
CRIT=$3

RAW_USAGE=`/usr/bin/sudo /usr/sbin/lvdisplay ${LVNAME} | /usr/bin/awk 'FNR == 12 {print $4}' | /usr/bin/tr -d '%'`
USAGE=`/usr/bin/printf "%.0f" ${RAW_USAGE}`

if [ ${USAGE} -lt ${WARN} ]; then
        echo "OK - ${USAGE}% used"
        exit 0
elif [ ${USAGE} -ge ${CRIT} ]; then
        echo "CRITICAL - ${USAGE}% used"
        exit 2
elif [ ${USAGE} -ge ${WARN} ]; then
        echo "WARNING - ${USAGE}% used"
        exit 1
else
        echo "ERROR - USAGE NOT CALCULATED"
        exit 2
fi
