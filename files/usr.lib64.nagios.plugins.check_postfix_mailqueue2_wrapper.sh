#!/bin/bash
sudo -u postfix /usr/lib64/nagios/plugins/check_postfix_mailqueue2.sh "$@"
