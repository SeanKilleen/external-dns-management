# Copyright (c) 2018 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the LICENSE file
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#############      builder       #############
FROM golang:1.21.6 AS builder

WORKDIR /build

# Copy go mod and sum files
COPY go.mod go.sum ./
# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

COPY . .

RUN make release

############# base
FROM gcr.io/distroless/static-debian11:nonroot AS base

#############      dns-controller-manager     #############
FROM base AS dns-controller-manager
WORKDIR /

COPY --from=builder /build/dns-controller-manager /dns-controller-manager

WORKDIR /

USER 65534:65534

ENTRYPOINT ["/dns-controller-manager"]
