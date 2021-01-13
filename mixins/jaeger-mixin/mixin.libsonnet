local certmanager = import "cert-manager-mixin/mixin.libsonnet";

{
  _config+:: {
    certManagerJobLabel: 'cert-manager',
    certManagerCertExpiryDays: '30',
    // grafanaExternalUrl: 'https://grafana.example.com',
  },
}
