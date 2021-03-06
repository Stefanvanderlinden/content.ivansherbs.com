#!/usr/bin/env bash

readonly target_dir=${TARGET_DIR}

readonly repo_dir=`dirname "$0"`/..
readonly repo_name=$(basename `git -C "${repo_dir}" rev-parse --show-toplevel`)

pushd "${repo_dir}" > /dev/null

echo "[`date`] Checking for new versions for repository: ${repo_name} (${PWD})"

git fetch

readonly content_commits_behind=`git rev-list HEAD..origin/master --count */`

if [ ${content_commits_behind} -gt 0 ]
then
  # report the detected changes
  echo "[`date`] Removing the files that need an update from target directory: ${target_dir}"
  git rev-list HEAD..origin/master | xargs git show --pretty="" --name-only | uniq | sed 's/\.md/.html/' | xargs -I "{}" echo -e "\t> {}"

  # remove the files that will be changed
  git rev-list HEAD..origin/master | xargs git show --pretty="" --name-only | uniq | sed 's/\.md/.html/' | xargs -I "{}" rm -f "${target_dir}/{}"
else
  echo "[`date`] No content updates found in the content source files"
fi

readonly repo_commits_behind=`git rev-list HEAD..origin/master --count`

if [ ${repo_commits_behind} -gt 0 ]
then
  # pull the updates for the source content files
  git pull
else
  echo "[`date`] No other updates found in the content repo"
fi

echo "[`date`] Finished checking for new versions for repository: ${repo_name} (${PWD})"
