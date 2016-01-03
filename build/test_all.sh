#!/bin/bash

source `dirname $0`/env.sh

test_count=0
skip_count=0
failure_count=0
code=0
result_collector=''

start_time=$SECONDS

for md in `get_markdown`
do
  test_count=`expr $test_count + 1`
  echo -n "${md}: " >&2
  if [ -s "${md}" ]
  then
    error_message=`$PANDOC -o "${md%.*}.pdf" "${md}" 2>&1`
    if [ $? -eq 0 ]
    then
      result_collector="${result_collector}<testcase classname=\"${md}\" name=\"`basename ${md}`\" />
"
      echo "OK" >&2
    else
      failure_count=`expr $failure_count + 1`
      result_collector="${result_collector}<testcase classname=\"${md}\" name=\"`basename ${md}`\">
  <error type=\"pandoc\"><![CDATA[${error_message}]]></error>
</testcase>
"
      code=1
      echo "$error_message" >&2
    fi
  else
    skip_count=`expr $skip_count + 1`
    result_collector="${result_collector}<testcase classname=\"${md}\" name=\"`basename ${md}`\">
  <skipped />
</testcase>
"
    echo "No Content" >&2
  fi
done

elapsed=`expr $SECONDS - $start_time`

echo "<?xml version=\"1.0\" ?>
<testsuite name=\"pandoc\" tests=\"${test_count}\" failures=\"${failure_count}\" time=\"${elapsed}\">
${result_collector}</testsuite>" >"${CIRCLE_TEST_REPORTS}/TestResults.xml"

exit $code

