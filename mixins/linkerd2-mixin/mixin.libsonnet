local linkerd2 = import "linkerd2-mixin/mixin.libsonnet";

linkerd2 {
  _config+:: {
    dashboard: {
      namePrefix: 'Linkerd2 / ',
      tags: ['linkerd2-mixin',],
    }
  },
}
