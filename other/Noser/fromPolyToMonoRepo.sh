#!/bin/bash

# This script creates a mono-repo

# Preconditions: (https://superuser.com/questions/1563034/how-do-you-install-git-filter-repo)
# *Python should be installed and added to the system's path.
# *Git should be installed and git also added to the system's path.
# *Download git-filter-repo
# *Replace 'python3' on first line of file called git-filter-repo with 'python'. Depending on your python installation, you may skip this step.
# *Call git --exec-path
# *Move the git-filter-repo file into that location shown. (git's path).
# *To use, type git filter-repo. The help option will not work, but they have documentation online.

# run the script in git bash
# BEFORE running the script replace {YOUR-*} with your actual values

# First git repo source
FIRST_SOURCE= "https://github.com"
REPOS=("{YOUR-PROJECT-A}" "{YOUR-PROJECT-B}")

for REPO in "${REPOS[@]}"; do
# * Workaround https://github.com/dart-lang/pub/issues/3803 => -c core.longpaths=true
  git clone "$FIRST_SOURCE/$REPO.git" -c core.longpaths=true
  cd "$REPO/" || exit
  git filter-repo --to-subdirectory-filter "$REPO" --tag-rename '':"$REPO-"
  cd ../
done

# Second git repo source
SECOND_SOURCE="https://bitbucket.org"
REPOS=("{YOUR-PROJECT-C}" "{YOUR-PROJECT-D}")

for REPO in "${REPOS[@]}"; do
  git clone "$SECOND_SOURCE/$REPO.git" -c core.longpaths=true
  cd "$REPO/" || exit
  git filter-repo --to-subdirectory-filter "$REPO" --tag-rename '':"$REPO-"
  cd ../
done

REPOS=("{YOUR-PROJECT-A}" "{YOUR-PROJECT-B}" "{YOUR-PROJECT-C}" "{YOUR-PROJECT-D}")

MERGED_REPO="{YOUR-MERGED-REPO-NAME}"
mkdir $MERGED_REPO
cd $MERGED_REPO || exit
git init

for REPO in "${REPOS[@]}"; do
  git remote add "$REPO" "../$REPO"
  git fetch "$REPO" --tags
  git fetch "$REPO"
  for BRANCH in $(git branch -r | grep "$REPO/" | sed "s/ *$REPO\///"); do
    git checkout -b "$REPO/$BRANCH" "$REPO/$BRANCH"
  done
  git remote remove "$REPO"
done

# manually merge main
git checkout "{YOUR-PROJECT-A}/main"
git merge --allow-unrelated-histories "{YOUR-PROJECT-B}/main" && git branch -d "{YOUR-PROJECT-B}/main"
git merge --allow-unrelated-histories "{YOUR-PROJECT-C}/main" && git branch -d "{YOUR-PROJECT-A}/main"
git merge --allow-unrelated-histories "{YOUR-PROJECT-D}/main" && git branch -d "{YOUR-PROJECT-A}/main"
git branch -m main

git checkout main
git remote add origin {YOUR-FINAL-SOURCE}/{YOUR-MONOREPO-NAME}.git
git push -u origin --all
git push -u origin HEAD:main