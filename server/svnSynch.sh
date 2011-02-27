# This scipt synchronizes GIT and SVN repositories
# IT SHOULD BE RUN WITH "bash -e svnSynch.sh" !!!
#
# It assumes repository was taken with 
# git-svn init http://host:port/svn/repos/pathToTrunk myRepo
# cd myRepo
# git config svn.authorsfile /path/toFile/thanMapsSvnUsersToGitUserEmails/
# git-svn fetch           or        git-svn fetch > ../out.txt 2>&1 &
# (this one may take 12+ hours, so maybe run in background - 2nd one)
# git-svn show-ignore > .gitignore
#
# Note that you will need to patch git-svn scipt wherever you have it installed.
# It is a perls script so no worries. Find "require Term::ReadKey;"
# and comment lines with # until Term::ReadKey::ReadMode('restore');
# then set my $password = ''; or whatever value you need for given user
#
# This script should be run every 5 minutes or so.
# it will feth all the SVN changes and dcommit all the git changes.
# If conflicts occures script exits, the parent script should send email.
# Someone will need to resolve conflicts manually, probably with
# git-svn fetch
# git merge -s recursive -X ours git-svn
# git-svn dcommit --username=piotrp
# or in worst case git reset --hard somehwereBeforeProblemsStarted, 
# then git-svn rebase, then git-clone on each client
#
# I noticed that it is totally safe to keep no branches and whenever you have one, 
# just remove it with git reset --hard pointBeforeBranchingBeggins
# To avoid having branches never do git pull. Do git fetch instead.
# If you use scripts from client directory (svnPull.sh, svnPush.sh) then you are golden.
#
# Go to the bottom of the file for more configuration options

log(){
  echo "`date +"%F %k:%M:%S"` [$localBranchName] $1"
}

svnSynch(){
  #giving nice name to function parameters
  localBranchName=$1
  svnBranchName=$2
  # checkout local branch
  git checkout $localBranchName > /dev/null 2>$1
  # Fetch most recent SVN changes first
  git-svn fetch

  svnChanges=`git log --pretty="%h" $localBranchName..$svnBranchName`
  gitChanges=`git log --pretty="%h" $svnBranchName..$localBranchName`

  if [ -n "$svnChanges" -o -n "$gitChanges" ] ; then
    log "Synchronization started"
    # Dont accept pushes for a while
    git config receive.denyCurrentBranch "refuse"
    # Wait for any pending pushes to finish
    sleep 30
    # Required on non bare repositories that allows pushing changes
    git reset --hard > /dev/null 2>$1
    # Put git changes on top of SVN recent changes
    git-svn rebase || {
      log "standard rebase failed, aborting and retrying"
      git rebase --abort
      git-svn rebase -s ours
    }
    if [ -n "$gitChanges" ] ; then
      # Commit all Git changes to SVN with single user.
      # ---> Ask Git commiters to put theit name in commit message
      git-svn dcommit --username=piotrp
    fi
    log "Synchronization ended"
  else
    log "Nothing to synchronize"
  fi
}

# Here you can call synchronizing function for trunk and each branch you have configured
svnSynch "master" "git-svn"
#svnSynch "master-2009.5" "git-svn-2009.5"

# After all synchronization is done continue accepting pushes
git config receive.denyCurrentBranch "ignore"