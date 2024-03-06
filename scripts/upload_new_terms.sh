#!/bin/bash

# This script should be called _after_ building the project. Part of building the project
# is running lupdate, and thus producing .../path/to/build/dir/i18n/venus-gui-v2.ts

file_to_upload=$1
echo "file to upload: $file_to_upload"
if [ "${POEDITOR_TOKEN}" == "" ]
then
  echo "Please set environment variable POEDITOR_TOKEN first"
  exit 1
fi


if [ ! -f $file_to_upload ]
then
  echo "File $file_to_upload not found"
  exit 1
fi

echo "### Uploading terms to POEditor: $file_to_upload"
curl -X POST https://api.poeditor.com/v2/projects/upload \
     -F api_token="${POEDITOR_TOKEN}" \
     -F id="674443" \
     -F updating="terms" \
     -F sync_terms=1 \
     -F file=@"$file_to_upload"

exit 0
