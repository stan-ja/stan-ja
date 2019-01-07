#!/bin/bash

source `dirname $0`/env.sh
chapter=${1:-`echo $CIRCLE_BRANCH | sed -e 's/^.*\(chap[0-9]*\).*$/\1/'`}
if [ -z "$chapter" ]
then
  echo "No Chapter" >&2
  exit 1
fi

target=`get_markdown | grep $chapter`
if [ -z "$target" ]
then
  echo "No Input" >&2
  exit 1
fi

if [ ! -d "${CIRCLE_ARTIFACTS:-.}" ]
then
  mkdir -p "${CIRCLE_ARTIFACTS:-.}"
fi

$PANDOC_PDF \
  -o "${CIRCLE_ARTIFACTS:-.}/stan-reference-2.16.0-ja-$chapter.pdf" \
  $target
$PANDOC_HTML \
  -o "${CIRCLE_ARTIFACTS:-.}/stan-reference-2.16.0-ja-$chapter.html" \
  $target

