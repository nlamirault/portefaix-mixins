local memcached = import "memcached-mixin/mixin.libsonnet";

memcached {
  _config+:: {
    
    // runbookURLPattern: 'https://doc.skale-5.com/run/runbook.md#alert-name-%s',
  },
}