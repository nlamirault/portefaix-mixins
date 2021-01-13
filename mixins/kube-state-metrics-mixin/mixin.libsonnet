local kubestatemetrics = import "kube-state-metrics-mixin/mixin.libsonnet";

kubestatemetrics {
  _config+:: {
    // Select the metrics coming from the kube state metrics.
    kubeStateMetricsSelector: 'job="kube-state-metrics"',

    // runbookURLPattern: 'https://doc.skale-5.com/run/runbook.md#alert-name-%s',

  },
}