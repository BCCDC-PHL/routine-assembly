#!/bin/bash

for image_file in ./apptainer-build/*.sif; do
    echo "Pushing image ${image_file}..."
    IMAGE_NAME=$(basename ${image_file} .sif)
    echo IMAGE_NAME=$IMAGE_NAME
    IMAGE_ID=ghcr.io/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME}
    echo IMAGE_ID=$IMAGE_ID
    VERSION=$(echo "${GITHUB_REF}" | sed -e 's,.*/\(.*\),\1,')
    [[ "${GITHUB_REF}" == "refs/tags/"* ]] && VERSION=$(echo $VERSION | sed -e 's/^v//')
    [ "$VERSION" == "main" ] && VERSION=latest
    echo IMAGE_ID=$IMAGE_ID
    echo VERSION=$VERSION
    echo "Pushing $image to $IMAGE_ID:$VERSION..."
    echo ${{ secrets.GITHUB_TOKEN }} | apptainer registry login -u ${{ secrets.GHCR_USERNAME }} --password-stdin oras://ghcr.io
done
