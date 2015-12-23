#!/bin/bash

source `dirname $0`/env.sh
target=`find . -name "chap*.md" | sort`

$PANDOC -o "$CIRCLE_ARTIFACTS/stan-reference-2.9.0-ja.pdf" $target

