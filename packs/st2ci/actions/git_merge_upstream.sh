#!/bin/bash
set -e

NAME=$1
REPO=$2
REPO_BRANCH=$3
REPO_UPSTREAM=$4
REPO_UPSTREAM_BRANCH=$5
REPO_DIR=$6
EXPECTED_COMMIT_SHA=$7

# Create the parent directory if it doesn't exists.
if [[ ! -d "${REPO_DIR}" ]]; then
    mkdir -p ${REPO_DIR}
fi

# If repo already cloned, remove it.
if [[ -d "${REPO_DIR}/${NAME}" ]]; then
    rm -rf ${REPO_DIR}/${NAME}
fi

# Clone git repo and merge with upstream.
echo "Cloning ${REPO} to ${REPO_DIR}..."
cd ${REPO_DIR}
git clone ${REPO}

echo "Adding upstream repo ${REPO_UPSTREAM}..."
cd ${REPO_DIR}/${NAME}
git remote add upstream ${REPO_UPSTREAM}

if [[ ${REPO_BRANCH} != "master" ]]; then
    echo "Checking out origin ${REPO_BRANCH}..."
    git checkout -b ${REPO_BRANCH} origin/${REPO_BRANCH}
fi

echo "Fetching upstream..."
git fetch upstream

echo "Merging upstream/${REPO_UPSTREAM_BRANCH}..."
git merge upstream/${REPO_UPSTREAM_BRANCH}

# Exit if the current commit sha is not the same as expected.
COMMIT_SHA=`git rev-parse HEAD`
echo "Latest commit sha: ${COMMIT_SHA}"

if [[ ${COMMIT_SHA} != ${EXPECTED_COMMIT_SHA} ]]; then
    echo "ERROR: Latest commit does not match (${COMMIT_SHA} != ${EXPECTED_COMMIT_SHA})."
    exit 1
fi

# Push change to origin.
set +e
echo "Pushing to origin ${REPO_BRANCH}..."
git push origin ${REPO_BRANCH}
if [[ $? != 0 ]]
then
    >&2 echo "ERROR: Unable to push change to origin ${REPO_BRANCH}."
    echo "Cleaning up..."
    rm -rf ${REPO_DIR}/${NAME}
    exit 1
fi

# Cleanup
echo "Cleaning up..."
rm -rf ${REPO_DIR}/${NAME}
