#!/bin/bash
if [ $# == 3 ] ; then
  # from string($1) remove everything from the $3 onwards.
  # ppref contains, therefore, everything before the $3
  A="${1%${3}*}";
  # from string($1) remove everything upto and including the suffix($2)
  # ssuff contains, therefore,everything after the suffix
  echo "${A#*${2}}";
else
  echo "Usage: substr.sh string from to"
fi