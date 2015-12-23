#!/bin/bash

source `dirname $0`/env.sh
chapter=`echo $CIRCLE_BRANCH | sed -e 's/^.*\(chap[0-9]*\).*$/\1/'`
target=`find . -name "chap*.md" | grep $chapter`

$PANDOC -o "$CIRCLE_ARTIFACTS/stan-reference-2.9.0-ja-$chapter.pdf" $target

