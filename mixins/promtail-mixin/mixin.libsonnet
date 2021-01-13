local promtail = import "promtail-mixin/mixin.libsonnet";

promtail {
  _config+:: {

    // runbookURLPattern: 'https://doc.skale-5.com/run/runbook.md#alert-name-%s',
  },
}