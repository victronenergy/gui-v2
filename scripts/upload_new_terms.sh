#!/bin/bash

# This script should be called _after_ building the project. Part of building the project
# is running `lupdate`, and thus producing i18n/venus-gui-v2.ts

if [ "${POEDITOR_TOKEN}" == "" ]
then
  echo "Please set environment variable POEDITOR_TOKEN first"
  exit 1
fi

if [ ! -f i18n/venus-gui-v2.ts ]
then
  echo "No i18n/venus-gui-v2.ts found"
  exit 1
fi

echo "### Uploading terms to POEditor"
curl -X POST https://api.poeditor.com/v2/projects/upload \
     -F api_token="${POEDITOR_TOKEN}" \
     -F id="674443" \
     -F updating="terms" \
     -F sync_terms=1 \
     -F file=@"i18n/venus-gui-v2.ts"

exit 0
