#!/bin/bash
cd /opt/portal/git/public/ehc
while true ; do
  bash -e /opt/portal/git/bin/svnSynch.sh
  if [ $? -gt 0 ] ; then
    echo "Synchronization failed"
    echo "SVN synch failed. This is last 100 lines of log" > /opt/portal/git/bin/tmpEhc
    tail -100 /opt/portal/git/bin/ehcSynch.log >> /opt/portal/git/bin/tmpEhc
    mail -s "svnSynch.sh failed" "yourmail@domain.com" < /opt/portal/git/bin/tmpEhc
    rm /opt/portal/git/bin/tmpEhc
    exit
  fi
  sleep 1m
done