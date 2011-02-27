# This script should be used to push your local changes 
# to central GIT repository that is synchonized with SVN
# It handles scenarios that may occure due to this set up
# 
# First try to push changes hoping no one made changes before you
response=`git push 2>&1`
if [[ "$response" == *rejected* ]] ; then
  if [[ "$response" == *non-fast-forward* ]] ; then
    echo "Origin has more recent sources, please svnPull.sh first"    
  else
    echo "git push failed for unknown reason"
    echo "$response"
  fi
else
  echo "$response"
  echo "Your changes are now on central GIT repo and will be pushed to SVN soon"
fi

