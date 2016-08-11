#!/bin/bash

source `dirname $0`/env.sh

if [ -z "$GITHUB_API_TOKEN" ]
then
  echo "No API Token" >&2
  exit 0
fi

artifact_filepath_base="${CIRCLE_ARTIFACTS}/stan-reference-2.9.0-ja"
artifact_filepath_pdf="${artifact_filepath_base}.pdf"
artifact_filepath_html="${artifact_filepath_base}.html"
if [ ! -e "$artifact_filepath_pdf" ]
then
  echo "No Artifact PDF" >&2
  exit 0
fi
if [ ! -e "$artifact_filepath_html" ]
then
  echo "No Artifact HTML" >&2
  exit 0
fi

build_path="gh/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/${CIRCLE_BUILD_NUM}"
build_url="https://circleci.com/${build_path}"

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

code=0

# PDF のデプロイ
curl \
  -X POST \
  -H "Authorization: token $GITHUB_API_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/pdf" \
  --data-binary @${artifact_filepath_pdf} \
  "$release_upload_url?name=`basename ${artifact_filepath_pdf}`"
if [ $? -ne 0 ]
then
  code=1
fi

# HTML のデプロイ
curl \
  -X POST \
  -H "Authorization: token $GITHUB_API_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: text/html; charset=utf-8" \
  --data-binary @${artifact_filepath_html} \
  "$release_upload_url?name=`basename ${artifact_filepath_html}`"
if [ $? -ne 0 ]
then
  code=1
fi

exit $code

