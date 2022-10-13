resource "kubernetes_namespace" "elasticsearch" {
  metadata {
    name = "elasticsearch"
    labels = {
      istio-injection      = "enabled"
      managed_by_terraform = "true"
    }
  }
}

# The following resource will create the operator ONLY.
# the actual Elastic Search clusters should be deployed by
# executing kubectl apply -n <namespace> -f operators/elasticsearch-<es-cluster>.yml
# Managing CRD in terraform is experimental.
resource "helm_release" "elasticsearch" {
  name       = "eck"
  chart      = "eck-operator"
  version    = "1.8.0"
  namespace  = kubernetes_namespace.elasticsearch.id
  repository = "https://helm.elastic.co"
}


resource "kubectl_manifest" "graylog_es" {
  depends_on = [
    helm_release.elasticsearch
  ]
  yaml_body = <<YAML
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: elasticsearch-graylog
  namespace: graylog
spec:
  version: 7.10.2
  http:
    tls:
      selfSignedCertificate:
        disabled: true
  nodeSets:
  - name: master
    count: 3
    config:
      node.roles: ["master",]
      indices.lifecycle.history_index_enabled: false
      xpack.security.authc:
          anonymous:
            username: anonymous
            roles: superuser
            authz_exception: false
    podTemplate:
      metadata:
        labels:
          role: graylog
      spec:
        initContainers:
        - name: sysctl
          securityContext:
            privileged: true
          command: ['sh', '-c', 'sysctl -w vm.max_map_count=262144']
        containers:
        - name: elasticsearch
          resources:
            requests:
              memory: 2Gi
              cpu: 1
          env:
          - name: ES_JAVA_OPTS
            value: "-Xms2g -Xmx2g -Dlog4j2.formatMsgNoLookups=true"
        tolerations:
        # - key: "sku"
        #   operator: "Equal"
        #   value: "memory"
        #   effect: "NoSchedule"
    volumeClaimTemplates:
    - metadata:
        name: elasticsearch-data
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 50Gi
        storageClassName: do-block-storage-retain
  - name: data
    count: 3
    config:
      node.roles: ["data", "ingest", "ml"]
      indices.lifecycle.history_index_enabled: false
      xpack.security.authc:
          anonymous:
            username: anonymous
            roles: superuser
            authz_exception: false
    podTemplate:
      metadata:
        labels:
          role: graylog
      spec:
        initContainers:
        - name: sysctl
          securityContext:
            privileged: true
          command: ['sh', '-c', 'sysctl -w vm.max_map_count=262144']
        containers:
        - name: elasticsearch
          resources:
            requests:
              memory: 2Gi
              cpu: 1
          env:
          - name: ES_JAVA_OPTS
            value: "-Xms2g -Xmx2g -Dlog4j2.formatMsgNoLookups=true"
        tolerations:
        # - key: "sku"
        #   operator: "Equal"
        #   value: "memory"
        #   effect: "NoSchedule"
    volumeClaimTemplates:
    - metadata:
        name: elasticsearch-data
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 50Gi
        storageClassName: do-block-storage-retain
  - name: ingest
    count: 3
    config:
      node.roles: ["ingest", "ml"]
      indices.lifecycle.history_index_enabled: false
      xpack.security.authc:
          anonymous:
            username: anonymous
            roles: superuser
            authz_exception: false
    podTemplate:
      metadata:
        labels:
          role: graylog
      spec:
        initContainers:
        - name: sysctl
          securityContext:
            privileged: true
          command: ['sh', '-c', 'sysctl -w vm.max_map_count=262144']
        containers:
        - name: elasticsearch
          resources:
            requests:
              memory: 2Gi
              cpu: 1
          env:
          - name: ES_JAVA_OPTS
            value: "-Xms2g -Xmx2g -Dlog4j2.formatMsgNoLookups=true"
        tolerations:
        # - key: "sku"
        #   operator: "Equal"
        #   value: "memory"
        #   effect: "NoSchedule"
    volumeClaimTemplates:
    - metadata:
        name: elasticsearch-data
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 50Gi
        storageClassName: do-block-storage-retain
YAML
}
