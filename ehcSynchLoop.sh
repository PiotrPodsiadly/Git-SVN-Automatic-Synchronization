#!/bin/bash
cd /opt/portal/git/public/ehc
while true ; do
  bash -e /opt/portal/git/bin/svnSynch.sh
  if [ $? -gt 0 ] ; then
    echo "Synchronization failed"
    exit
  fi
  sleep 1m
done
