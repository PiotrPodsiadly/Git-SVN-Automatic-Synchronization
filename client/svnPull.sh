# This script should be used to update your local GIT repo 
# from central GIT repository that is synchonized with SVN
# It handles 'git-svn rebase' that happens on git server side
# 
currentBranchName=`git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
remoteBranchName="origin/$currentBranchName"

# First fetch changes from central repo
response=`git fetch 2>&1`
if [[ "$response" == *"forced update"* ]] ; then
  echo "$response"
  echo "Origin changed the order of commits with rebase command."
  echo "You needto reset your local history to match it."
  echo "Trying simple reset..."
  git reset "$remoteBranchName"
  echo "Try to commit your files again, revert any unstaged file that you did not touched"
  echo "If that fails, you will need to abandon your changes with:   git reset --hard $remoteBranchName"
  # This also happens when you modify file X and commit and SVN did modified it as well
  # When you checkin X with 1 line, do commit, svnPush. Then add 2 line and commit and svnPush and
  # central repo synchronized the changes in between your pushes 
  # and you did not run svnPull before your 2nd checkin, then you will have conflict. 
  # To prevent that you should always svnPull.sh before commit  
else
  echo "$response"
  # See if you are behind 
  fullLine=`git branch -v --no-color 2> /dev/null | sed -e '/^[^*]/d'`
  betweenBrackets=`substr.sh "$fullLine" "[" "]"`
  if [[ "$betweenBrackets" == *behind* ]] ; then
    echo "Looks like you are behind - rebasing your changes"
    git rebase "$remoteBranchName"
  fi
fi
