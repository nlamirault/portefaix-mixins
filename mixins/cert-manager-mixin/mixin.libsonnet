local certmanager = import 'cert-manager-mixin/mixin.libsonnet';

certmanager {
  _config+:: {
    certManagerJobLabel: 'cert-manager',
    certManagerCertExpiryDays: '30',
  },
}
