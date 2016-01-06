#!/bin/bash

source `dirname $0`/env.sh

if [ -z "$CI_PULL_REQUEST" ]
then
  echo "Not PR" >&2
  exit 0
fi

if [ -z "$GITHUB_API_TOKEN" ]
then
  echo "No API Token" >&2
  exit 0
fi

chapter=`echo $CIRCLE_BRANCH | sed -e 's/^.*\(chap[0-9]*\).*$/\1/'`
if [ -z "$chapter" ]
then
  echo "No Chapter" >&2
  exit 1
fi

artifact_filepath="${CIRCLE_ARTIFACTS}/stan-reference-2.9.0-ja-$chapter.pdf"
artifact_url="https://circle-artifacts.com/gh/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/${CIRCLE_BUILD_NUM}/artifacts/${CIRCLE_NODE_INDEX}${artifact_filepath}"
username=`echo $CI_PULL_REQUEST | sed -e 's/^https:\/\/github.com\/\(.*\)\/\(.*\)\/pull\/\([0-9]*\)$/\1/'`
reposname=`echo $CI_PULL_REQUEST | sed -e 's/^https:\/\/github.com\/\(.*\)\/\(.*\)\/pull\/\([0-9]*\)$/\2/'`
pr_number=`echo $CI_PULL_REQUEST | sed -e 's/^https:\/\/github.com\/\(.*\)\/\(.*\)\/pull\/\([0-9]*\)$/\3/'`
api_url="https://api.github.com/repos/${username}/${reposname}/issues/${pr_number}/comments"
message="{ \"body\": \"[PDF for ${CIRCLE_SHA1}](${artifact_url})\" }"

curl \
  -X POST \
  -H "Authorization: token $GITHUB_API_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d "$message" \
  "$api_url"

