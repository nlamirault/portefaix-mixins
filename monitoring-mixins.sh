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
        rm -fr kubernetes-mixin
    fi
    echo -e "${INFO_COLOR}[monitoring-mixins] Clone repository kubernetes-mixin${NO_COLOR}"
    git clone https://github.com/kubernetes-monitoring/kubernetes-mixin
    pushd kubernetes-mixin

    echo -e "${INFO_COLOR}[monitoring-mixins] Generate Prometheus alert/rules and Grafana dashboards${NO_COLOR}"
    jb install
    rm -fr prometheus_alerts.yaml prometheus_rules.yaml dashboards_out
    # make prometheus_alerts.yaml
    jsonnet -J vendor -S lib/alerts.jsonnet | gojsontoyaml > prometheus_alerts.yaml
    # make prometheus_rules.yaml
    jsonnet -J vendor -S lib/rules.jsonnet | gojsontoyaml > prometheus_rules.yaml
    make dashboards_out
    popd
    mkdir -p ${output}/kubernetes-mixin/dashboards
    cp -r kubernetes-mixin/dashboards_out/*.json ${output}/kubernetes-mixin/dashboards/
    cp -r kubernetes-mixin/prometheus_alerts.yaml ${output}/kubernetes-mixin
    cp -r kubernetes-mixin/prometheus_rules.yaml ${output}/kubernetes-mixin
}


function node_mixin {
    output=$1
    echo -e "${INFO_COLOR}[monitoring-mixins] Retrieve NodeExporter Mixin ${NO_COLOR}"
    if [[ -d node-mixin ]]; then
        rm -fr node_exporter
    fi
    echo -e "${INFO_COLOR}[monitoring-mixins] Clone repository node_exporter${NO_COLOR}"
    git clone https://github.com/prometheus/node_exporter
    pushd node_exporter/docs/node-mixin

    echo -e "${INFO_COLOR}[monitoring-mixins] Generate Prometheus alert/rules and Grafana dashboards${NO_COLOR}"
    jb install
    # TODO: make a Github issue
    # make node_alerts.yaml
    jsonnet -S alerts.jsonnet | gojsontoyaml > node_alerts.yaml
    # make node_rules.yaml
    jsonnet -S rules.jsonnet | gojsontoyaml > node_rules.yaml

    make dashboards_out
    popd
    mkdir -p ${output}/node-mixin/dashboards
    cp -r node_exporter/docs/node-mixin/dashboards_out/*.json ${output}/node-mixin/dashboards/
    cp -r node_exporter/docs/node-mixin/node_alerts.yaml ${output}/node-mixin
    cp -r node_exporter/docs/node-mixin/node_rules.yaml ${output}/node-mixin
}


function prometheus_mixin {
    output=$1
    echo -e "${INFO_COLOR}[monitoring-mixins] Retrieve Prometheus Mixin ${NO_COLOR}"
    if [[ -d prometheus ]]; then
        rm -fr prometheus
    fi
    echo -e "${INFO_COLOR}[monitoring-mixins] Clone repository prometheus${NO_COLOR}"
    git clone https://github.com/prometheus/prometheus
    pushd prometheus/documentation/prometheus-mixin

    if [[ -d grafonnet-lib ]]; then
        cd grafonnet-lib
        git pull
        cd ..
    else
        git clone https://github.com/grafana/grafonnet-lib.git
    fi
    ln -s grafonnet-lib/grafonnet grafonnet

    echo -e "${INFO_COLOR}[monitoring-mixins] Generate Prometheus alert/rules and Grafana dashboards${NO_COLOR}"
    jb install
    rm -fr prometheus_alerts.yaml dashboards_out
    # TODO: make an issue on Github project
    # make prometheus_alerts.yaml
    jsonnet -S alerts.jsonnet | gojsontoyaml > prometheus_alerts.yaml
    make dashboards_out
    popd
    mkdir -p ${output}/prometheus-mixin/dashboards
    cp -r prometheus/documentation/prometheus-mixin/dashboards_out/*.json ${output}/prometheus-mixin/dashboards/
    cp -r prometheus/documentation/prometheus-mixin/prometheus_alerts.yaml ${output}/prometheus-mixin
}


function etcd_mixin {
    output=$1
    echo -e "${INFO_COLOR}[monitoring-mixins] Retrieve Etcd Mixin ${NO_COLOR}"
    if [[ -d etcd ]]; then
        rm -fr etcd
    fi
    echo -e "${INFO_COLOR}[monitoring-mixins] Clone repository Etcd${NO_COLOR}"
    git clone https://github.com/etcd-io/etcd.git
    pushd etcd/Documentation/etcd-mixin

    echo -e "${INFO_COLOR}[monitoring-mixins] Generate Prometheus alert/rules and Grafana dashboards${NO_COLOR}"
    jb install
    jsonnet -e '(import "mixin.libsonnet").prometheusAlerts' | gojsontoyaml > etcd_alerts.yaml
    jsonnet -e '(import "mixin.libsonnet").grafanaDashboards' > etcd_mixin.json
    popd
    mkdir -p ${output}/etcd-mixin/dashboards
    cp -r etcd/Documentation/etcd-mixin/etcd_alerts.yaml ${output}/etcd-mixin
    cp -r etcd/Documentation/etcd-mixin/*.json ${output}/etcd-mixin/dashboards
}

function elasticsearch_mixin {
    output=$1
    echo -e "${INFO_COLOR}[monitoring-mixins] Retrieve Elasticsearch Mixin ${NO_COLOR}"
    if [[ -d elasticsearch-mixin ]]; then
        rm -fr elasticsearch-mixin
    fi
    echo -e "${INFO_COLOR}[monitoring-mixins] Clone repository elasticsearch-mixin${NO_COLOR}"
    git clone https://github.com/lukas-vlcek/elasticsearch-mixin.git
    pushd elasticsearch-mixin

    echo -e "${INFO_COLOR}[monitoring-mixins] Generate Prometheus alert/rules and Grafana dashboards${NO_COLOR}"
    jb install
    make prometheus_alerts.yaml prometheus_rules.yaml dashboards_out
    popd
}


function loki_mixin {
    output=$1
    echo -e "${INFO_COLOR}[monitoring-mixins] Retrieve Loki Mixin ${NO_COLOR}"
    if [[ -d loki ]]; then
        rm -fr loki
    fi
    echo -e "${INFO_COLOR}[monitoring-mixins] Clone repository loki-mixin${NO_COLOR}"
    git clone https://github.com/grafana/loki
    pushd loki/production/loki-mixin

    echo -e "${INFO_COLOR}[monitoring-mixins] Generate Prometheus alert/rules and Grafana dashboards${NO_COLOR}"
    jb install
    echo "std.manifestYamlDoc((import 'mixin.libsonnet').prometheusAlerts)" > alerts.jsonnet
    cat << EOF > dashboards.jsonnet
    local dashboards = (import 'mixin.libsonnet').dashboards;
    {
    [name]: dashboards[name]
    for name in std.objectFields(dashboards)
    }
EOF

    echo -e "${INFO_COLOR}[monitoring-mixins] Generate Prometheus alert/rules and Grafana dashboards${NO_COLOR}"
    jsonnet -S alerts.jsonnet | gojsontoyaml > loki_alerts.yaml
    mkdir -p dashboards_out
    jsonnet -J vendor -m dashboards_out dashboards.jsonnet
    popd

    mkdir -p ${output}/loki-mixin/dashboards
    cp -r loki/production/loki-mixin/loki_alerts.yaml ${output}/loki-mixin
    cp -r loki/production/loki-mixin/dashboards_out/*.json ${output}/loki-mixin/dashboards
}

function kube_state_metrics_mixin {
    output=$1
    echo -e "${INFO_COLOR}[monitoring-mixins] Retrieve KubeStateMetrics Mixin ${NO_COLOR}"
    if [[ -d kube-state-metrics ]]; then
        rm -fr kube-state-metrics
    fi
    echo -e "${INFO_COLOR}[monitoring-mixins] Clone repository kube-state-metrics${NO_COLOR}"
    git clone https://github.com/kubernetes/kube-state-metrics
    pushd kube-state-metrics

    echo -e "${INFO_COLOR}[monitoring-mixins] Generate Prometheus alert/rules and Grafana dashboards${NO_COLOR}"
    make install-tools
    make mixin

    popd
    mkdir -p ${output}/kube-state-metrics-mixin/
    cp -r kube-state-metrics/examples/prometheus-alerting-rules/alerts.yaml ${output}/kube-state-metrics-mixin/
}


function thanos_mixin {
    output=$1
    echo -e "${INFO_COLOR}[monitoring-mixins] Retrieve Thanos Mixin ${NO_COLOR}"
    if [[ -d thanos ]]; then
        rm -fr thanos
    fi
    echo -e "${INFO_COLOR}[monitoring-mixins] Clone repository Thanos${NO_COLOR}"
    git clone https://github.com/thanos-io/thanos
    pushd thanos

    echo -e "${INFO_COLOR}[monitoring-mixins] Generate Prometheus alert/rules and Grafana dashboards${NO_COLOR}"
    make jsonnet-vendor
    make examples/dashboards
    make examples/alerts/alerts.yaml
    make examples/alerts/rules.yaml

    popd
    mkdir -p ${output}/thanos-mixin/
    cp -r thanos/examples/alerts/rules.yaml ${output}/thanos-mixin
    cp -r thanos/examples/alerts/alerts.yaml ${output}/thanos-mixin
    cp -r thanos/examples/dashboards ${output}/thanos-mixin
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