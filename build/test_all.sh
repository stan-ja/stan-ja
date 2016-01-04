#!/bin/bash

source `dirname $0`/env.sh

tmpfile=$(mktemp)

test_count=0
skip_count=0
failure_count=0
code=0
result_collector=''
total_elapsed=0

for md in `get_markdown`
do
  test_count=`expr $test_count + 1`
  echo -n "${md}: " >&2
  if [ -s "${md}" ]
  then
    time_test=`(time $PANDOC -o "${md%.*}.pdf" "${md}" 2>&1) 2>&1 >"$tmpfile"`
    time_test=`echo $time_test | cut -d' ' -f2 | sed -e 's/^\(.*\)m\(.*\)s$/60*\1+\2/' | bc`
    total_elapsed=`echo "$total_elapsed + $time_test" | bc`
    error_message=`cat "$tmpfile"`
    if [ $? -eq 0 ]
    then
      result_collector="${result_collector}<testcase classname=\"${md}\" name=\"`basename ${md}`\" time=\"${time_test}\" />
"
      echo "OK" >&2
    else
      failure_count=`expr $failure_count + 1`
      result_collector="${result_collector}<testcase classname=\"${md}\" name=\"`basename ${md}`\" time=\"${time_test}\">
  <failure type=\"pandoc\"><![CDATA[${error_message}]]></failure>
</testcase>
"
      code=1
      echo "$error_message" >&2
    fi
  else
    skip_count=`expr $skip_count + 1`
    result_collector="${result_collector}<testcase classname=\"${md}\" name=\"`basename ${md}`\" time=\"0\">
  <skipped />
</testcase>
"
    echo "No Content" >&2
  fi
done

echo "<?xml version=\"1.0\" ?>
<testsuites>
<testsuite name=\"pandoc\" tests=\"${test_count}\" failures=\"${failure_count}\" time=\"${total_elapsed}\">
${result_collector}</testsuite>
</testsuites>" >"${CIRCLE_TEST_REPORTS}/TestResults.xml"

rm "$tmpfile"

exit $code

