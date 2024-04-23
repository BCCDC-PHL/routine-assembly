#!/bin/bash

for image_file in ./apptainer-build/*.sif; do
    echo "Pushing image ${image_file}..."
    IMAGE_NAME=$(basename ${image_file} .sif)
    echo IMAGE_NAME=$IMAGE_NAME
    IMAGE_ID=ghcr.io/${{ github.repository_owner }}/${IMAGE_NAME}
    echo IMAGE_ID=$IMAGE_ID
    IMAGE_ID=$(echo $IMAGE_ID | tr '[A-Z]' '[a-z]')
    echo IMAGE_ID=$IMAGE_ID
    VERSION=$(echo "${{ github.ref }}" | sed -e 's,.*/\(.*\),\1,')
    [[ "${{ github.ref }}" == "refs/tags/"* ]] && VERSION=$(echo $VERSION | sed -e 's/^v//')
    [ "$VERSION" == "main" ] && VERSION=latest
    echo IMAGE_ID=$IMAGE_ID
    echo VERSION=$VERSION
    echo "Pushing $image to $IMAGE_ID:$VERSION..."
done
