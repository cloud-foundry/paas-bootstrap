#!/bin/bash

set -euo pipefail

: $ONS_PREFIX
: $ENVIRONMENT
: $NAMESPACE

prefix=${ONS_PREFIX}-${ENVIRONMENT}-${NAMESPACE}

NAMES=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, '${prefix}')].Name" --output text)

echo "Removing all versions from ${prefix}-* (${NAMES})"

function emptyBucket {

  echo "Emptying $1"
  local bucket=$1;

  local versions=$(aws s3api list-object-versions --bucket "$bucket" | jq '.Versions')
  local markers=$(aws s3api list-object-versions --bucket "$bucket" | jq '.DeleteMarkers')
  count=$(($(echo $versions | jq 'length')-1))

  if [ $count -gt -1 ]; then
    echo "removing files"
    for i in $(seq 0 $count); do
      key=$(echo $versions | jq ".[$i].Key" | sed -e 's/\"//g')
      versionId=$(echo $versions | jq ".[$i].VersionId" | sed -e 's/\"//g')
      echo "- $bucket $key $versionId"
      aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$versionId"
    done
  fi

  count=$(($(echo $markers | jq 'length')-1))

  if [ $count -gt -1 ]; then
    echo "removing delete markers"

    for i in $(seq 0 $count); do
      key=$(echo $markers | jq ".[$i].Key" | sed -e 's/\"//g')
      versionId=$(echo $markers | jq ".[$i].VersionId" | sed -e 's/\"//g')
      echo "- $bucket $key $versionId"
      aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$versionId"
    done
  fi

  return 0
}

for name in $NAMES
do
    emptyBucket ${name}
done