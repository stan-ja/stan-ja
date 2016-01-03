#!/bin/bash

source `dirname $0`/env.sh

if [ -z "$GITHUB_API_TOKEN" ]
then
  echo "No API Token" >&2
  exit 0
fi

artifact_filepath="${CIRCLE_ARTIFACTS}/stan-reference-2.9.0-ja.pdf"
if [ ! -e "$artifact_filepath" ]
then
  echo "No Artifact" >&2
  exit 0
fi

build_path="gh/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/${CIRCLE_BUILD_NUM}"
build_url="https://circleci.com/${build_path}"
artifact_url="https://circle-artifacts.com/${build_path}/artifacts/${CIRCLE_NODE_INDEX}${artifact_filepath}"

release_create_url="https://api.github.com/repos/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/releases"
release_name="stan-reference-2.9.0-ja draft version ${CIRCLE_BUILD_NUM}"
release_body="[ビルドログ](${build_url})"
release_message="{ \"tag_name\": \"build-${CIRCLE_BUILD_NUM}\", \"target_commitish\": \"${CIRCLE_SHA1}\", \"name\": \"${release_name}\", \"body\": \"${release_body}\", \"prerelease\": true }"

release_upload_url=$(curl \
  -X POST \
  -H "Authorization: token $GITHUB_API_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d "$release_message" \
  "$release_create_url" \
  | jq ".upload_url" \
  | sed -e 's/^"\(.*\){.*}"$/\1/'
)

if [ "$release_upload_url" = "null" ]
then
  echo "Release Failed" >&2
  exit 1
fi

curl \
  -X POST \
  -H "Authorization: token $GITHUB_API_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/pdf" \
  --data-binary @${artifact_filepath} \
  "$release_upload_url?name=`basename ${artifact_filepath}`"

