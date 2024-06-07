#!/bin/bash

mkdir -p apptainer-build
pushd apptainer-build > /dev/null

for env_yaml in ../environments/*.yml; do
    image_name=$(head -n 1 $env_yaml | cut -d ' ' -f 2)
    echo "building image ${image_name} from file ${env_yaml}..."
    wave \
	--conda-file ${env_yaml} \
	--singularity \
	--freeze \
	--await \
	--output json
done


