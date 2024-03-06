#!/bin/bash

# This script is used for fetching the latest translations
# from POEditor, making sure that the release uses the
# most up to date translations. It is typically called from the GitHub
# action, via the cmake build system, and only running on tagged releases.
# 
# example usage: cmake /path/to/CMakeLists.txt; make download_translations
# example usage: download_from_poeditor.sh uk /path/to/gui-v2/i18n/venus-gui-v2_uk.ts


if [ "${POEDITOR_TOKEN}" == "" ]
then
  echo "Please set environment variable POEDITOR_TOKEN first"
  exit 1
fi

code=${1/_/-}

output_file=$2
echo "### Fetching ${code}, storing in ${output_file}"
download_url=$(curl -X POST https://api.poeditor.com/v2/projects/export \
  -d api_token="${POEDITOR_TOKEN}" \
  -d id="674443" \
  -d type="ts" \
  -d language="${code}" |\
   jq -r '.result.url')

if [ "${download_url}" == "null" ]
then
  echo "### Unable to determine download url for code [${code}]"
  exit 1
else
  curl -X GET ${download_url} --output ${output_file}
fi

exit 0
