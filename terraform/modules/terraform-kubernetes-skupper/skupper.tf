resource "kubectl_manifest" "serviceaccount_skupper_site_controller" {
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: skupper-site-controller
  namespace: ${var.namespace}
  labels:
    application: skupper-site-controller
YAML
}

resource "kubectl_manifest" "role_skupper_site_controller" {
  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    application: skupper-site-controller
  name: skupper-site-controller
  namespace: ${var.namespace}
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  - pods
  - pods/exec
  - services
  - secrets
  - serviceaccounts
  verbs:
  - get
  - list
  - watch
  - create
  - update
  - delete
- apiGroups:
  - apps
  resources:
  - deployments
  - statefulsets
  - daemonsets
  verbs:
  - get
  - list
  - watch
  - create
  - update
  - delete
- apiGroups:
  - route.openshift.io
  resources:
  - routes
  verbs:
  - get
  - list
  - watch
  - create
  - delete
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  - networkpolicies
  verbs:
  - get
  - list
  - watch
  - create
  - delete
- apiGroups:
  - projectcontour.io
  resources:
  - httpproxies
  verbs:
  - get
  - list
  - watch
  - create
  - delete
- apiGroups:
  - rbac.authorization.k8s.io
  resources:
  - rolebindings
  - roles
  verbs:
  - get
  - list
  - watch
  - create
  - delete
YAML
}

resource "kubectl_manifest" "rolebinding_skupper_site_controller" {
  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    application: skupper-site-controller
  name: skupper-site-controller
  namespace: ${var.namespace}
subjects:
- kind: ServiceAccount
  name: skupper-site-controller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: skupper-site-controller
YAML
}

resource "kubectl_manifest" "deployment_skupper_site_controller" {
  yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: skupper-site-controller
  namespace: ${var.namespace}
spec:
  replicas: 1
  selector:
    matchLabels:
      application: skupper-site-controller
  template:
    metadata:
      labels:
        application: skupper-site-controller
    spec:
      serviceAccountName: skupper-site-controller
      containers:
      - name: site-controller
        image: quay.io/skupper/site-controller:1.0.0
        env:
        - name: WATCH_NAMESPACE
          valueFrom:
             fieldRef:
               fieldPath: metadata.namespace
YAML
}

resource "kubectl_manifest" "namespace_skupper_site" {
  depends_on = [
    kubectl_manifest.deployment_skupper_site_controller
  ]
  yaml_body = <<YAML
apiVersion: v1
data:
  cluster-local: "false"
  console: "true"
  console-authentication: internal
  console-password: "marketcircle"
  console-user: "marketcircle"
  edge: "${var.skupper_edge}"
  name: ${var.cluster_name}-${var.namespace}-site
  router-console: "true"
  service-controller: "true"
  service-sync: "true"
kind: ConfigMap
metadata:
  name: skupper-site
  namespace: ${var.namespace}
YAML
}