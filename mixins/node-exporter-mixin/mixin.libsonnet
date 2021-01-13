local nodeExporter = import "node-mixin/mixin.libsonnet";

nodeExporter {

  _config+:: {
    nodeExporterSelector: 'job="node"',

    // Available disk space (%) thresholds on which to trigger the
    // 'NodeFilesystemSpaceFillingUp' alerts. These alerts fire if the disk
    // usage grows in a way that it is predicted to run out in 4h or 1d
    // and if the provided thresholds have been reached right now.
    // In some cases you'll want to adjust these, e.g. by default Kubernetes
    // runs the image garbage collection when the disk usage reaches 85%
    // of its available space. In that case, you'll want to reduce the
    // critical threshold below to something like 14 or 15, otherwise
    // the alert could fire under normal node usage.
    fsSpaceFillingUpWarningThreshold: 40,
    fsSpaceFillingUpCriticalThreshold: 20,

    // Available disk space (%) thresholds on which to trigger the
    // 'NodeFilesystemAlmostOutOfSpace' alerts.
    fsSpaceAvailableCriticalThreshold: 10,
    fsSpaceAvailableWarningThreshold: 20,

    grafana_prefix: 'Node Exporter / ',

    grafanaK8s+:: {
      dashboardNamePrefix: 'Kubernetes Mixin / ',
      dashboardTags: ['kubernetes', 'infrastucture', "minotor-v4"],
    },
  },
}