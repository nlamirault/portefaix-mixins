local etcd = import "etcd-mixin/mixin.libsonnet";

etcd {
  _config+:: {
    etcd_selector: 'job=~".*etcd.*"',
    // etcd_instance_labels are the label names that are uniquely
    // identifying an instance and need to be aggreated away for alerts
    // that are about an etcd cluster as a whole. For example, if etcd
    // instances are deployed on K8s, you will likely want to change
    // this to 'instance, pod'.
    etcd_instance_labels: 'instance',
    // scrape_interval_seconds is the global scrape interval which can be
    // used to dynamically adjust rate windows as a function of the interval.
    scrape_interval_seconds: 30,
    
    // runbookURLPattern: 'https://doc.skale-5.com/run/runbook.md#alert-name-%s',
  },
}