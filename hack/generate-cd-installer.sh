#!/bin/bash
#
# Copyright (c) 2023 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the LICENSE file
#
# SPDX-License-Identifier: Apache-2.0

set -e

SOURCE_PATH="$(dirname $0)/.."
IMAGE_REGISTRY="$(${SOURCE_PATH}/hack/get-image-registry.sh)"
CD_REGISTRY="$(${SOURCE_PATH}/hack/get-cd-registry-installer.sh)"
GINST="${GARDENER_INSTALLER_CLI:-ginst}"

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

echo "using $GINST"
$GINST comp create --ocm-name ${PROJECT} --repository ${CD_REGISTRY} --source "${SOURCE_PATH}/.installer"  --internal-images ${RESOURCES_FILE_PATH} -v

