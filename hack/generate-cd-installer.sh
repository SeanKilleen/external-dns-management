#!/bin/bash
#
# Copyright (c) 2023 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the LICENSE file
#
# SPDX-License-Identifier: Apache-2.0

set -e

SOURCE_PATH="$(dirname $0)/.."
IMAGE_REGISTRY="$(${SOURCE_PATH}/hack/get-image-registry.sh)"
CD_REGISTRY=eu.gcr.io/gardener-project/test/martinweindel/ocmsetup1

echo "> Adding image of dns-controller-manager"
RESOURCES_BASE_PATH="$(mktemp -d)"
RESOURCES_FILE_PATH="${RESOURCES_BASE_PATH}/images.yaml"
cat << EOF > ${RESOURCES_FILE_PATH}
images:
  - name: dns-controller-manager
    repository: ${IMAGE_REGISTRY}/dns-controller-manager
    version: ${EFFECTIVE_VERSION}
EOF

echo "> Creating component descriptor and pushing it"

ginst comp create --repository ${CD_REGISTRY} --source "${SOURCE_PATH}/.installer"  --internal-images ${RESOURCES_FILE_PATH} -v

