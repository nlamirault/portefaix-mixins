local thanos = import "mixin/mixin.libsonnet";

thanos {
  dashboard+:: {
    prefix: 'Thanos / ',
    tags: ['thanos-mixin', "minotor-v4.1.0"],
    namespaceQuery: 'kube_pod_info',
  },
}
