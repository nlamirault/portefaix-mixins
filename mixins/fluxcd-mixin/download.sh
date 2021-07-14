#!/bin/bash

# Copyright (C) 2021 Nicolas Lamirault <nicolas.lamirault@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

OK_COLOR="\e[32m"
KO_COLOR="\e[31m"
NO_COLOR="\e[39m"
INFO_COLOR="\e[36m"

REPO_URL="https://raw.githubusercontent.com/fluxcd/flux2"
REPO_VERSION="v0.16.1"

curl -so "dashboards/cluster.json" "${REPO_URL}/${REPO_VERSION}/manifests/monitoring/grafana/dashboards/cluster.json"
curl -so "dashboards/control-plane.json" "${REPO_URL}/${REPO_VERSION}/manifests/monitoring/grafana/dashboards/control-plane.json"