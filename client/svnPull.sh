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
  echo "Trying simple reset"
  git reset "$remoteBranchName"
  # When you see "master -> origin/master (forced update) just run
  # git reset --hard origin/master and you will catch up with what has been rebased with svn-rebase
  #
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
