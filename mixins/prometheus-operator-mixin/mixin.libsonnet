local prometheusOperator = import "mixin/mixin.libsonnet";

prometheusOperator {
  _config+:: {
    prometheusOperatorSelector: 'job="prometheus-operator"',
  },
}
