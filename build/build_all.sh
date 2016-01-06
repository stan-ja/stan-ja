#!/bin/bash

source `dirname $0`/env.sh
target=`get_markdown`

$PANDOC \
  --toc \
  -o "${CIRCLE_ARTIFACTS:-.}/stan-reference-2.9.0-ja.pdf" \
  $target

