#!/bin/bash

source `dirname $0`/env.sh

code=0

for md in `find . -name "chap*.md"`
do
  echo -n "${md}: " >&2
  if [ -s "${md}" ]
  then
    $PANDOC -o "${md%.*}.pdf" "${md}"
    if [ $? -eq 0 ]
    then
      echo "OK" >&2
    else
      code=1
    fi
  else
    echo "No Content" >&2
  fi
done

exit $code

