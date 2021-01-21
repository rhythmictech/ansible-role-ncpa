#!/bin/bash
# created by McArt <hello@mcart.ru> http://www.mcart.ru/
 
# Uncomment to enable debugging
# set -x
 
PROGNAME=`basename $0`
VERSION="Version 2.0"
AUTHOR="McArt (http://www.mcart.ru)"
 
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
 
warning=unknown
critical=unknown
 
print_version() {
    echo "$PROGNAME $VERSION $AUTHOR"
}
 
print_help() {
    print_version $PROGNAME $VERSION
    echo ""
    echo "$PROGNAME - Checks postfix mailqueue statistic"
    echo ""
    echo "$PROGNAME is a Nagios plugin which generates statistics"
    echo "for the postfix mailqueue and checks for corrupt messages."
	echo "The following values will be checked:"
	echo "active: Mails being delivered (should be small)"
	echo "deferred: Stuck mails (that will be retried later)"
	echo "corrupt: Messages found to not be in correct format (should be 0)"
	echo "hold: Recent addition, messages put on hold indefinitly - delete of free"
	echo "bounced: Bounced mails"
    echo ""
    echo "Usage: $PROGNAME -w WARN-Level -c CRIT-Level"
    echo ""
    echo "Options:"
    echo "  -w)"
    echo "     Warning level for active mails"
    echo "  -c)"
    echo "     Critical level for active mail"
    echo "  -h)"
    echo "     This help"
    echo "  -v)"
    echo "     Version"
    exit $STATE_OK
}
 
# Check for parameters
while test -n "$1"; do
    case "$1" in
		-h)
			print_help
			exit $STATE_OK;;
		-v)
			print_version
			exit $STATE_OK;;
		-w)
			warning=$2
			shift
			;;
		-c)
			critical=$2
			shift
			;;
		*)
			echo "Usage: ./check_postfix_mailqueue2.sh -w <Warning level for active mails> -c <Critical level for active mail>"
			;;
	esac
	shift
done

if [ $warning == "unknown" ] || [ $critical == "unknown" ]; then
	echo "You need to specify warning and critical for active mails"
	echo "Usage: ./check_postfix_mailqueue2.sh -w <warn> -c <crit>"
	exit $STATE_UNKNOWN
fi

# make sure CRIT is larger than WARN
if [ $warning -ge $critical ];then
	echo "UNKNOWN: WARN value may not be greater than or equal the CRIT value"
	exit $OK
fi
 
check_postfix_mailqueue() {
# Can be set via environment, but default is fetched by postconf (if available,
# else /var/spool/postfix) 
if which postconf > /dev/null ; then
   SPOOLDIR=${spooldir:-`postconf -h queue_directory`}
else
   SPOOLDIR=${spooldir:-/var/spool/postfix}
fi
 
cd $SPOOLDIR >/dev/null 2>/dev/null || {
     echo -n "Cannot cd to $SPOOLDIR"
     exit $STATE_CRITICAL
}
 
for d in deferred active corrupt hold
do
  if [ ! -r $d ]
  then
      echo -n "queue dir '$d' is not readable"
      exit $STATE_CRITICAL
  fi
done
 
# Get values
deferred=`(test -d deferred && find deferred -type f ) | wc -l`
#active=`(test -d active && find active -type f ) | wc -l`
corrupt=`(test -d corrupt && find corrupt -type f ) | wc -l`
hold=`( test -d hold && find hold -type f ) | wc -l`
#bounced=`grep bounced /var/log/maillog | wc -l`
}

#Check with bounced mesages 
#check_postfix_mailqueue
#values="Deferred mails=$deferred Active deliveries=$active Corrupt mails=$corrupt Mails on hold=$hold Bounced mails=$bounced"
#perfdata="deferred=$deferred;; active=$active;; corrupt=$corrupt;; hold=$hold;; bounced=$bounced;;"

#Check without bounced messages and active deliveries
check_postfix_mailqueue
values="Deferred mails=$deferred Corrupt mails=$corrupt Mails on hold=$hold"
perfdata="deferred=$deferred;; corrupt=$corrupt;; hold=$hold;;"
 
if [ $corrupt -gt $warning ]; then
	echo -n "Postfix Mailqueue WARNING - $corrupt corrupt messages found! | $perfdata"
	exit $STATE_WARNING
fi

if [ $hold -gt $warning ]; then
	echo -n "Postfix Mailqueue WARNING - $hold hold messages found! | $perfdata"
	exit $STATE_WARNING
fi

if [ $deferred -gt $warning ]; then
	echo -n "Postfix Mailqueue WARNING - $deferred deferred messages found! | $perfdata"
	exit $STATE_WARNING
fi

#if $warning[ $bounced -gt 0 ]; then
#	echo -n "Postfix Mailqueue WARNING - $bounced bounced messages found! | $perfdata"
#	exit $STATE_WARNING
#fi


#   if [ $active -gt $critical ]; then
#      MES_TO_EXIT="Postfix Mailqueue CRITICAL - $values | $perfdata"
#      STATE_TO_EXIT=$STATE_CRITICAL
#   elif [ $active -gt $warning ]; then
#      MES_TO_EXIT="Postfix Mailqueue WARNING - $values | $perfdata"
#      STATE_TO_EXIT=$STATE_WARNING
#   else
      MES_TO_EXIT="Postfix Mailqueue OK - $values | $perfdata"
      STATE_TO_EXIT=$STATE_OK
#   fi


echo -n $MES_TO_EXIT
echo -e "\n"
exit $STATE_TO_EXIT
