#!/bin/bash

# Copyright (C) 2019 OPS Team <ops@skale-5.com>

OK_COLOR="\e[32m"
KO_COLOR="\e[31m"
NO_COLOR="\e[39m"
INFO_COLOR="\e[34m"



function kubernetes_mixin {
    output=$1
    echo -e "${INFO_COLOR}[monitoring-mixins] Retrieve Kubernetes Mixin ${NO_COLOR}"
    if [[ -d kubernetes-mixin ]]; then
        echo -e "${INFO_COLOR}kubernetes-mixin exists, updating${NO_COLOR}"
        pushd kubernetes-mixin
        git pull
    else
        echo -e "${INFO_COLOR}Clone repository kubernetes-mixin${NO_COLOR}"
        git clone https://github.com/kubernetes-monitoring/kubernetes-mixin
        pushd kubernetes-mixin
    fi
    jb install
    echo -e "${INFO_COLOR}[monitoring-mixins] Generate Kubernetes Mixin ${NO_COLOR}"
    make prometheus_alerts.yaml
    make prometheus_rules.yaml
    make dashboards_out
    popd
    mkdir -p ${output}/kubernetes-mixin/dashboards
    cp -r kubernetes-mixin/dashboards_out/* ${output}/kubernetes-mixin/dashboards/
    cp -r kubernetes-mixin/prometheus_alerts.yaml ${output}/kubernetes-mixin
    cp -r kubernetes-mixin/prometheus_rules.yaml ${output}/kubernetes-mixin
}


function node_mixin {
    output=$1
    echo -e "${INFO_COLOR}[monitoring-mixins] Retrieve NodeExporter Mixin ${NO_COLOR}"
    if [[ -d node-mixin ]]; then
        echo -e "${INFO_COLOR}node-mixin exists, updating${NO_COLOR}"
        pushd node_exporter/docs/node-mixin
        git pull
    else
        echo -e "${INFO_COLOR}Clone repository node_exporter${NO_COLOR}"
        git clone https://github.com/prometheus/node_exporter
        pushd node_exporter/docs/node-mixin
    fi
    jb install
    echo -e "${INFO_COLOR}[monitoring-mixins] Generate NodeExporter Mixin ${NO_COLOR}"
    make node_alerts.yaml
    make node_rules.yaml
    make dashboards_out
    popd
    mkdir -p ${output}/node-mixin/dashboards
    cp -r node_exporter/docs/node-mixin/dashboards_out/* ${output}/node-mixin/dashboards/
    cp -r node_exporter/docs/node-mixin/node_alerts.yaml ${output}/node-mixin
    cp -r node_exporter/docs/node-mixin/node_rules.yaml ${output}/node-mixin
}


function prometheus_mixin {
    output=$1
    echo -e "${INFO_COLOR}[monitoring-mixins] Retrieve Prometheus Mixin ${NO_COLOR}"
    if [[ -d prometheus ]]; then
        echo -e "${INFO_COLOR}prometheus-mixin exists, updating${NO_COLOR}"
        pushd prometheus/documentation/prometheus-mixin
        git pull
    else
        echo -e "${INFO_COLOR}Clone repository prometheus${NO_COLOR}"
        git clone https://github.com/prometheus/prometheus
        pushd prometheus/documentation/prometheus-mixin
    fi
    if [[ -d grafonnet-lib ]]; then
        cd grafonnet-lib
        git pull
        cd ..
    else
        git clone https://github.com/grafana/grafonnet-lib.git
    fi
    ln -s grafonnet-lib/grafonnet grafonnet
    jb install
    echo -e "${INFO_COLOR}[monitoring-mixins] Generate Prometheus Mixin ${NO_COLOR}"
    rm -fr prometheus_alerts.yaml dashboards_out
    make prometheus_alerts.yaml
    make dashboards_out
    popd
    mkdir -p ${output}/prometheus-mixin/dashboards
    cp -r prometheus/documentation/prometheus-mixin/dashboards_out/* ${output}/prometheus-mixin/dashboards/
    cp -r prometheus/documentation/prometheus-mixin/prometheus_alerts.yaml ${output}/prometheus-mixin
}


function etcd_mixin {
    output=$1
    echo -e "${INFO_COLOR}[monitoring-mixins] Retrieve Etcd Mixin ${NO_COLOR}"
    if [[ -d etcd ]]; then
        echo -e "${INFO_COLOR}etcd-mixin exists, updating${NO_COLOR}"
        pushd etcd/Documentation/etcd-mixin
        git pull
    else
        echo -e "${INFO_COLOR}Clone repository Etcd${NO_COLOR}"
        git clone https://github.com/etcd-io/etcd.git
        pushd etcd/Documentation/etcd-mixin
    fi
    jb install
    echo -e "${INFO_COLOR}[monitoring-mixins] Generate Etcd Mixin ${NO_COLOR}"
    jsonnet -e '(import "mixin.libsonnet").prometheusAlerts' | gojsontoyaml > etcd_alerts.yaml
    popd
    mkdir -p ${output}/etcd-mixin/
    cp -r etcd/Documentation/etcd-mixin/etcd_alerts.yaml ${output}/etcd-mixin
}

function elasticsearch_mixin {
    output=$1
    echo -e "${INFO_COLOR}[monitoring-mixins] Retrieve Elasticsearch Mixin ${NO_COLOR}"
    if [[ -d elasticsearch-mixin ]]; then
        echo -e "${INFO_COLOR}elasticsearch-mixin exists, updating.${NO_COLOR}"
        pushd elasticsearch-mixin
        git pull
    else
        echo -e "${INFO_COLOR}Clone repository elasticsearch-mixin${NO_COLOR}"
        git clone https://github.com/lukas-vlcek/elasticsearch-mixin.git
        pushd elasticsearch-mixin
    fi
    jb install
    echo -e "${INFO_COLOR}[monitoring-mixins] Generate Elasticsearch Mixin ${NO_COLOR}"
    make prometheus_alerts.yaml prometheus_rules.yaml dashboards_out
    popd
}


function loki_mixin {
    output=$1
    echo -e "${INFO_COLOR}[monitoring-mixins] Retrieve Loki Mixin ${NO_COLOR}"
    if [[ -d loki-mixin ]]; then
        echo -e "${INFO_COLOR}loki-mixin exists, updating.${NO_COLOR}"
        pushd loki-mixin
        git pull
    else
        echo -e "${INFO_COLOR}Clone repository loki-mixin${NO_COLOR}"
        git clone https://github.com/grafana/loki
        pushd loki/production/loki-mixin
    fi
    jb install
    echo -e "${INFO_COLOR}[monitoring-mixins] Generate Loki Mixin ${NO_COLOR}"
    echo "std.manifestYamlDoc((import 'mixin.libsonnet').prometheusAlerts)" > alerts.jsonnet
    cat << EOF > dashboards.jsonnet
    local dashboards = (import 'mixin.libsonnet').dashboards;
    {
    [name]: dashboards[name]
    for name in std.objectFields(dashboards)
    }
EOF

    jsonnet -S alerts.jsonnet > loki_alerts.yaml
    mkdir -p dashboards_out
    jsonnet -J vendor -m dashboards_out dashboards.jsonnet
    popd
}

function kube_state_metrics_mixin {
    output=$1
    echo -e "${INFO_COLOR}[monitoring-mixins] Retrieve KubeStateMetrics Mixin ${NO_COLOR}"
    if [[ -d kube-state-metrics ]]; then
        echo -e "${INFO_COLOR}kube-state-metrics exists, updating.${NO_COLOR}"
        pushd kube-state-metrics
        git pull
    else
        echo -e "${INFO_COLOR}Clone repository kube-state-metrics${NO_COLOR}"
        git clone https://github.com/kubernetes/kube-state-metrics
        pushd kube-state-metrics
    fi
    make mixin
}


function thanos_mixin {
    output=$1
    echo -e "${INFO_COLOR}[monitoring-mixins] Retrieve Thanos Mixin ${NO_COLOR}"
    if [[ -d kube-thanos ]]; then
        echo -e "${INFO_COLOR}thanos exists, updating.${NO_COLOR}"
        pushd kube-thanos
        git pull
    else
        echo -e "${INFO_COLOR}Clone repository kube-thanos${NO_COLOR}"
        git clone https://github.com/thanos-io/kube-thanos
        pushd kube-thanos
    fi
    make jsonnet/thanos-mixin/dashboards
    make jsonnet/thanos-mixin/alerts.yaml
    make jsonnet/thanos-mixin/rules.yaml
    popd
    mkdir -p ${output}/thanos-mixin/
    cp -r kube-thanos/jsonnet/thanos-mixin/rules.yaml ${output}/thanos-mixin
    cp -r kube-thanos/jsonnet/thanos-mixin/alerts.yaml ${output}/thanos-mixin
    cp -r kube-thanos/jsonnet/thanos-mixin/dashboards ${output}/thanos-mixin
}



function usage() {
    echo "usage: $0 <mixin-choice> <output>"
    echo "Arguments:"
    echo "   mixin-choice      : which mixin to use"
    echo "   output            : directory for generated files"
}


if [ "$#" -ne 2 ]; then
    usage
    exit 0
fi

output=$2
mkdir -p ${output}

case $1 in
    kubernetes-mixin)
        kubernetes_mixin ${output}
        ;;
    node-mixin)
        node_mixin ${output}
        ;;
    prometheus-mixin)
        prometheus_mixin ${output}
        ;;
    loki-mixin)
        loki_mixin ${output}
        ;;
    etcd-mixin)
        etcd_mixin ${output}
        ;;
    elasticsearch-mixin)
        elasticsearch_mixin ${output}
        ;;
    thanos-mixin)
        thanos_mixin ${output}
        ;;
    # TODO:
    kube-state-metrics-mixin)
        kube_state_metrics_mixin ${output}
        ;;
    *)
        echo -e "${KO_COLOR}[monitoring-mixins] Invalid arguments ${NO_COLOR}"
        usage
        exit 1
        ;;
esac