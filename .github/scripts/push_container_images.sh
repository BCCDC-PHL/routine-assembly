#!/bin/bash

for image in ./apptainer-build/*.sif; do
  IMAGE_NAME=$(basename $image .sif)
  IMAGE_ID=ghcr.io/${{ github.repository_owner }}/$IMAGE_NAME
  IMAGE_ID=$(echo $IMAGE_ID | tr '[A-Z]' '[a-z]')
  VERSION=$(echo "${{ github.ref }}" | sed -e 's,.*/\(.*\),\1,')
  [[ "${{ github.ref }}" == "refs/tags/"* ]] && VERSION=$(echo $VERSION | sed -e 's/^v//')
  [ "$VERSION" == "main" ] && VERSION=latest
  echo IMAGE_ID=$IMAGE_ID
  echo VERSION=$VERSION
  echo "Pushing $image to $IMAGE_ID:$VERSION..."
done
