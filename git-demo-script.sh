#!/usr/bin/env bash

mkdir git-demo
cd git-demo/
mkdir repo1
cd repo1/

# Initialize a git repo in this directory. After running this command there will be a new
# directory .git in the current directory.
git init

# Create file1.txt. This file is initially not under version control.
echo "Hello World" > file1.txt

# git will show that file1.txt is untracked since it has not yet been added to version control.
git status

# Add file1.txt to the index. Adding a file to the index schedules it to be added to the
# repository.
git add file1.txt

# git now shows file1.txt in the index. More files can be added to the index. Whenever a file
# that is already under version control has been modified, it will also have to be added to the
# index. Only files that have been added to the index can be committed.
git status

# Commit all files that are in the index (in this case only file1.txt)
git commit -m "Added file1.txt"

# Launch a graphical tool that will show exactly one commit at this point. It is recommended
# to refresh the view of gitk after each of the following commands to observe how the
# commit graph changes over time.
gitk --all&

# Create a second file and modify the first file.
echo "Hello World" > file2.txt
git status
echo "Second line" >> file1.txt

# git status will show file2.txt as untracked and file1.txt as modified.
git status
git add file2.txt
git status
git add file1.txt

# git status will show both files as being added to the index.
git status

# Commit the changes. gitk will now show two commits. Note that gitk will color the
# currently checked out commit in yellow. gitk will show the newest commit at the top
# of the screen.
git commit -m "Added file2.txt"

# Create a branch. The new branch will be pointing to the same commit as master
# (the default initial branch).
git branch dev-branch

# Currently branch master is checked out.
git branch

# Checkout branch dev-branch
git checkout dev-branch

# Currently branch dev-branch is checked out
git branch

# Create file3.txt, add it to the index and then commit it. Note change in the commit
# graph with gitk. Branch master is now one commit behind branch dev-branch.
echo "Hello World" > file3.txt
git add file3.txt
git commit -m "Added file3.txt"

# Checkout branch master. Note that file3.txt disappeared since it is not in this branch.
# Also note that gitk will color the commit of master in yellow to indicate that it is currently
# checked out.
git checkout master
ls

# Checkout branch dev-branch. Note that file3.txt is now back in the directory and gitk
# will color the dev-branch commit in yellow.
git checkout dev-branch

# Merge master into dev-branch. Note that nothing happens since dev-branch already
# contains everything that is in master (master is an ancestor of dev-branch)
git merge master

# Checkout master
git checkout master

# Merge dev-branch into master. Note the change in gitk. Since dev-branch is a parent
# of master, git will perform a so-called fast-forward merge: no new commit is created
# and only the label of master is moved (fast-forwarded) to the label of dev-branch.
git merge dev-branch

# The following git command will effectively undo the previous merge. Branch master
# will be reset to HEAD^1 which denotes the first parent (^1) of the current commit (HEAD)
git reset --hard HEAD^1

# Create and checkout a new branch called second-dev-branch
git branch second-dev-branch
git checkout second-dev-branch

# Create and commit file4.txt to this branch
echo "Hello World" > file4.txt
git add file4.txt
git commit -m "Added file4.txt"

# Merge dev-branch into second-dev-branch. Note that this is not a simple fast-forward
# merge because dev-branch is not a direct ancestor of second-dev-branch. In this case
# git will create a new commit that has two parents for the two branches that have been
# merged.
git merge dev-branch

# The following command will again undo the merge. Note that the current commit has
# two parents. HEAD^1 refers to the first parent which will reset second-dev-branch to
# the earlier commit. This effectively deletes the commit that was created as part of the
# merge.
git reset --hard HEAD^1

# Rebase will search for the common ancestor of the current branch and dev-branch
# and 'replay' all the changes that were made in second-dev-branch since then onto
# dev-branch. The result is the same as the previous merge (files 1-4 will be in the
# directory), however, the commit graph will look different. Whereas merge creates
# a new commit with two parents, a rebase will just reorganize the commit graph.
# Rebase will make the commit graph look a little cleaner.
git rebase dev-branch

# Leave this repository and create a new empty repository.
cd ..
mkdir remote-repo
cd remote-repo/
git init

# This repo will represent the 'remote' repo (that would ordinarily be be hosted at
# github). It can be used to push and pull on the same machine without having to
# actually setup a remote repo. The following command will mark the repo a 'bare'
# which means is only serves as the target for push and pulls from other repos.
git config --bool core.bare true

# Go back to the first repo
cd ../repo1/

# Add a so-called remote. A remote points to a remote repo. The name of the repo
# is 'origin' and it points to the bare repo that was just setup. 'origin' is by convention
# the name of the repo from where this repo originated (which is not quite accurate
# for this repo since it was created with git init). The location of the remote repo is
# ../remote-repo. Ordinarily this would be a URL pointing to github.
git remote add origin ../remote-repo/

# Show the remote for this repo. Right now there is only one remote called 'origin'
git remote show

# Show details for the remote 'origin'
git remote show origin

# Checkout branch master
git checkout master

# Push all changes of the current branch (master) to the remote called 'origin'
# into a branch called 'master' at the remote repo. Note the changes in gitk. No
# new commits were added, however, a new label with the name of the remote
# branch was added, pointing to the same commit as master.
git push origin master

# Leave this repo
cd ..

# Clone the 'remote' repo into a new repo called 'repo2'
git clone remote-repo repo2

# cd into the new repo
cd repo2

# Start a second instance of gitk in this directory. Note that a remote branch was already
# setup (this is a side-effect of clone). Note that branch master in this repo reflects the
# state of branch master of repo1. In particular, you will not see the commits of dev-branch
# and second-dev-branch since those commits have not yet been pushed to the remote repo.
ls

# Go back to the first repo.
cd ../repo1/

# Merge master into second-dev-branch. Since the latter branch was rebased, this merge
# is a simple fast-forward merge. Note the change in gitk. Note that branch remote branch
# master is now two commits behind the local branch master. This is because those
# commits have not yet been pushed to the remote repo.
git merge second-dev-branch

# Delete the two development branches since the are no longer needed. Note the changes
# in gitk.
git branch -d dev-branch
git branch -d second-dev-branch

# Push changes to branch master to the remote repo. This will transmit all commits between
# the remote branch master and local branch master to the remote repo. Note the changes
# in the commit graph with gitk.
git push

# Change to the second repo.
cd ../repo2/

# Pull all changes from the remote repo. Since new commits were pushed previously from
# repo1, two new commits will be downloaded. The content of repo2 is now identical to the
# content of repo1.
git pull
ls

