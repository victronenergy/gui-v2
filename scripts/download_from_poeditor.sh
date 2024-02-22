#!/bin/bash

# This script is used for fetching the latest translations
# from POEditor, making sure that the release uses the
# most up to date translations. It is called from the GitHub
# action, and only running on tagged releases.
if [ "${POEDITOR_TOKEN}" == "" ]
then
  echo "Please set environment variable POEDITOR_TOKEN first"
  exit 1
fi

sed -ne 's/.*"i18n\/[^}]*}_\(.*\).ts"/\1/p' CMakeLists.txt |\
while read -r code
do
  output_file="i18n/venus-gui-v2_${code}.ts"
  echo "### Fetching ${code}"
  download_url=$(curl --silent -X POST https://api.poeditor.com/v2/projects/export \
    -d api_token="${POEDITOR_TOKEN}" \
    -d id="674443" \
    -d type="ts" \
    -d language="${code}" |\
     jq -r '.result.url')
  curl --silent -X GET ${download_url} --output ${output_file}

done

exit 0
