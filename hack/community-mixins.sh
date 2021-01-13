#!/bin/bash

# Copyright (C) 2020-2021 Nicolas Lamirault <nicolas.lamirault@gmail.com>

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

MIXINS_DIR="mixins"


function usage() {
    echo "usage: $0 <output directory>"
}

function jsonnet_tools {
    go get github.com/google/go-jsonnet/cmd/jsonnet
    go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
}

function monitoring_mixin {
    local mixin=$1
    local output=$2
    local alerts=$3
    local rules=$4
    local dashboards=$5
    local import=$6

    echo -e "${INFO_COLOR}[minotor-mixin] Setup Monitoring Mixin: ${mixin} ${NO_COLOR}"
    pushd ${MIXINS_DIR}/${mixin}
    if [ -f "jsonnetfile.lock.json" ]; then
        jb update
    else
        jb install
    fi
    mkdir -p ${output}/${mixin}/{prometheus,manifests,dashboards}
    echo -e "${INFO_COLOR}[minotor-mixin] Generate alerts${NO_COLOR}"
    if [ -n "${alerts}" ]; then
        jsonnet -J vendor -S -e 'std.manifestYamlDoc((import "mixin.libsonnet").prometheusAlerts)' | gojsontoyaml > ${output}/${mixin}/prometheus/alerts.yaml
    fi
    echo -e "${INFO_COLOR}[minotor-mixin] Generate rules${NO_COLOR}"
    if [ -n "${rules}" ]; then
        jsonnet -J vendor -S -e 'std.manifestYamlDoc((import "mixin.libsonnet").prometheusRules)' | gojsontoyaml > ${output}/${mixin}/prometheus/rules.yaml
    fi
    echo -e "${INFO_COLOR}[minotor-mixin] Generate dashboards${NO_COLOR}"
    if [ -n "${dashboards}" ]; then
        jsonnet -J vendor -m ${output}/${mixin}/dashboards -e "${import}"
    fi
    
    popd
}

function monitoring_mixin_mixtool {
    local mixin=$1
    local output=$2

    echo -e "${INFO_COLOR}[minotor-mixin] Setup Monitoring Mixin: ${mixin} ${NO_COLOR}"
    pushd ${MIXINS_DIR}/${mixin}

    mixtool generate all mixin.libsonnet
    mkdir -p ${output}/${mixin}/{prometheus,manifests,dashboards}
    mv alerts.yaml ${output}/${mixin}/prometheus
    mv rules.yaml ${output}/${mixin}/prometheus
    mv dashboards_out/*.json ${output}/${mixin}/dashboards

    popd
}


function alertmanager_mixin {
    local output=$1
    echo -e "${OK_COLOR}[minotor-mixin] Alertmanager Mixin ${NO_COLOR}"
    monitoring_mixin "alertmanager-mixin" ${output} "alerts" "" "" '(import "mixin.libsonnet").grafanaDashboards'
}

function kube_state_metrics_mixin {
    local output=$1
    echo -e "${OK_COLOR}[minotor-mixin] KubeStateMetrics Mixin ${NO_COLOR}"
    monitoring_mixin "kube-state-metrics-mixin" ${output} "alerts" "" "" '(import "mixin.libsonnet").grafanaDashboards'
}

function kubernetes_mixin {
    echo -e "${OK_COLOR}[minotor-mixin] Kubernetes Mixin ${NO_COLOR}"
    monitoring_mixin "kubernetes-mixin" ${output} "alerts" "rules" "dashboards" '(import "mixin.libsonnet").grafanaDashboards'
}

function node_exporter_mixin {
    echo -e "${OK_COLOR}[minotor-mixin] Setup Node Exporter Mixin ${NO_COLOR}"
    monitoring_mixin "node-exporter-mixin" ${output} "alerts" "rules" "dashboards" '(import "mixin.libsonnet").grafanaDashboards'
}


function prometheus_operator_mixin {
    echo -e "${OK_COLOR}[minotor-mixin] Setup Prometheus Operator Mixin ${NO_COLOR}"
    monitoring_mixin "prometheus-operator-mixin" ${output} "alerts" "" "" '(import "mixin.libsonnet").grafanaDashboards'
}


function prometheus_mixin {
    echo -e "${OK_COLOR}[minotor-mixin] Setup Prometheus Mixin ${NO_COLOR}"
    monitoring_mixin "prometheus-mixin" ${output} "alerts" "" "dashboards" '(import "mixin.libsonnet").grafanaDashboards'
}


function thanos_mixin {
    echo -e "${OK_COLOR}[minotor-mixin] Setup Thanos Mixin ${NO_COLOR}"
    monitoring_mixin "thanos-mixin" ${output} "alerts" "rules" "dashboards" '(import "mixin.libsonnet").grafanaDashboards'
}


function cert_manager_mixin {
    echo -e "${OK_COLOR}[minotor-mixin] Setup Cert Manager Mixin ${NO_COLOR}"
    monitoring_mixin "cert-manager-mixin" ${output} "alerts" "rules" "dashboards" '(import "mixin.libsonnet").grafanaDashboards'
}

function grafana_mixin {
    echo -e "${OK_COLOR}[minotor-mixin] Setup Grafana Mixin ${NO_COLOR}"
    monitoring_mixin_mixtool "grafana-mixin" ${output}
}

function loki_mixin {
    echo -e "${OK_COLOR}[minotor-mixin] Setup Loki Mixin ${NO_COLOR}"
    monitoring_mixin "loki-mixin" ${output} "alerts" "rules" "dashboards" '(import "mixin.libsonnet").grafanaDashboards'
}

function promtail_mixin {
    echo -e "${OK_COLOR}[minotor-mixin] Setup Promtail Mixin ${NO_COLOR}"
    monitoring_mixin "promtail-mixin" ${output} "alerts" "rules" "dashboards" '(import "mixin.libsonnet").grafanaDashboards'
}

function etcd_mixin {
    echo -e "${OK_COLOR}[minotor-mixin] Setup Etcd Mixin ${NO_COLOR}"
    monitoring_mixin "etcd-mixin" ${output} "alerts" "" "dashboards" '(import "mixin.libsonnet").grafanaDashboards'
}

function memcached_mixin {
    echo -e "${OK_COLOR}[minotor-mixin] Setup Memcached Mixin ${NO_COLOR}"
    monitoring_mixin "memcached-mixin" ${output} "alerts" "" "dashboards"  '(import "mixin.libsonnet").grafanaDashboards'
}

function linkerd2_mixin {
    echo -e "${OK_COLOR}[minotor-mixin] Setup Linkerd2 Mixin ${NO_COLOR}"
    monitoring_mixin "linkerd2-mixin" ${output} "" "" "dashboards" '(import "mixin.libsonnet").dashboards'
}


echo -e "${OK_COLOR}[ Monitoring Mixins ]${NO_COLOR}"

if [ "$#" -ne 1 ]; then
    usage
    exit 0
fi

output=$(pwd)/$1

kubernetes_mixin ${output}
node_exporter_mixin ${output}
prometheus_operator_mixin ${output}
prometheus_mixin ${output}
alertmanager_mixin ${output}
kube_state_metrics_mixin ${output}
thanos_mixin ${output}
cert_manager_mixin ${output}
grafana_mixin ${output}
loki_mixin ${output}
promtail_mixin ${output}
etcd_mixin ${output}
memcached_mixin ${output}
linkerd2_mixin ${output}

# TODO :

# elasticsearch_mixin

