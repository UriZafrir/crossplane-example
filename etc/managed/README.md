[![Datalayer](https://raw.githubusercontent.com/datalayer/datalayer/main/res/logo/datalayer-25.svg?sanitize=true)](https://datalayer.io)

# Crossplane Examples

Create the database and reference the connection secret it produces in a helm Release values.

- https://doc.crds.dev/github.com/crossplane-contrib/provider-helm/helm.crossplane.io/Release/v1beta1@v0.5.0#spec-forProvider-valuesFrom-secretKeyRef

- https://github.com/crossplane-contrib/provider-helm/blob/master/examples/sample/release.yaml

```yaml
apiVersion: helm.crossplane.io/v1beta1
kind: Release
metadata:
  name: wordpress-example
spec:
# rollbackLimit: 3
  forProvider:
    chart:
      name: wordpress
      repository: https://charts.bitnami.com/bitnami
      version: 9.3.19
#     pullSecretRef:
#       name: museum-creds
#       namespace: default
#     url: "https://charts.bitnami.com/bitnami/wordpress-9.3.19.tgz"
    namespace: wordpress
#   skipCreateNamespace: true
#   wait: true
    values:
      service:
        type: ClusterIP
    set:
      - name: param1
        value: value2
#   valuesFrom:
#     - configMapKeyRef:
#         key: values.yaml
#         name: default-vals
#         namespace: wordpress
#         optional: false
#     - secretKeyRef:
#         key: svalues.yaml
#         name: svals
#         namespace: wordpress
#         optional: false
#  connectionDetails:
#    - apiVersion: v1
#      kind: Service
#      name: wordpress-example
#      namespace: wordpress
#      fieldPath: spec.clusterIP
#      #fieldPath: status.loadBalancer.ingress[0].ip
#      toConnectionSecretKey: ip
#    - apiVersion: v1
#      kind: Service
#      name: wordpress-example
#      namespace: wordpress
#      fieldPath: spec.ports[0].port
#      toConnectionSecretKey: port
#    - apiVersion: v1
#      kind: Secret
#      name: wordpress-example
#      namespace: wordpress
#      fieldPath: data.wordpress-password
#      toConnectionSecretKey: password
#  writeConnectionSecretToRef:
#    name: wordpress-credentials
#    namespace: crossplane-system
  providerConfigRef:
    name: helm-provider
```
