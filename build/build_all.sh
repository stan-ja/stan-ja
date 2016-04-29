#!/bin/bash

source `dirname $0`/env.sh
target=`get_markdown`

$PANDOC_PDF \
  --toc \
  -o "${CIRCLE_ARTIFACTS:-.}/stan-reference-2.9.0-ja.pdf" \
  $target
$PANDOC_HTML \
  --toc \
  -o "${CIRCLE_ARTIFACTS:-.}/stan-reference-2.9.0-ja.html" \
  $target

