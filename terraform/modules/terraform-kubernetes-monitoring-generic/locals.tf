locals {
  slack_api_url             = var.slack_alerts_url
  pagerduty_integration_key = var.pagerduty_service_key
  pagerduty_service         = <<EOF
      pagerduty_configs:
      - routing_key: '${local.pagerduty_integration_key}'
EOF
  slack_page_service        = <<EOF
${local.pagerduty_service}
${local.slack_service}
EOF
  slack_service             = <<EOF
      slack_configs:
      - channel: '${var.slack_alerts_channel}'
        # api_url is set as a helm value using terraform/kms
        api_url: '${local.slack_api_url}'
        send_resolved: true
        icon_emoji: '{{ template "slack.default.iconemoji" . }}'
        color: |-
          {{ if eq .Status "firing" -}}
            {{ if eq .CommonLabels.severity "warning" -}}
              warning
            {{- else if eq .CommonLabels.severity "critical" -}}
              danger
            {{- else -}}
              #439FE0
            {{- end -}}
          {{ else -}}
          good
          {{- end }}
        # overridden by terraform
        title: '[{{ if eq .Status "firing" }}ALERTING:{{ .Alerts | len }}{{ else }}RESOLVED{{ end }}] ${var.cluster_name} - {{ .GroupLabels.SortedPairs.Values | join " " }}'
        title_link: '{{ template "slack.default.titlelink" . }}'
        pretext: '{{ .CommonAnnotations.summary }}'
        text: |-
          {{ if eq .Status "firing" -}}
               {{range .Alerts -}}
                 *Description:* {{.Annotations.description}}
                 {{- if gt (len .Labels.SortedPairs) 2 -}}{{printf "%s\n" ""}}*Details:*{{printf "%s\n" ""}}
                   {{- range .Labels.SortedPairs -}}{{if and (ne .Name "alertname") (ne .Name "severity")}} • *{{- .Name}}:* `{{.Value}}`{{printf "%s\n" ""}}{{end}}{{end}}
                 {{- else}}{{printf "%s\n" ""}}{{- end}}{{printf "%s\n" "---"}}{{end -}}
          {{ end }}
EOF
  alerts                    = <<EOF
serverFiles:
  alerts:
    groups:
    - name: "Pod metrics"
      rules:
        - alert: PodMemoryUsage
          expr: container_memory_rss / container_spec_memory_limit_bytes > 0.9 AND container_spec_memory_limit_bytes != 0
          for: 15m
          labels:
            severity: warning
          annotations:
            description: 'A pod in either the kube-system or prometheus is at 90% of its memory limit. Either setup an HPA for this pod type or tweak the resource requests. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
        - alert: PodOOMKill
          expr: kube_pod_container_status_last_terminated_reason{reason="OOMKilled"} - kube_pod_container_status_last_terminated_reason{reason="OOMKilled"} offset 5m > 0
          for: 1m
          labels:
            severity: critical
          annotations:
            description: 'Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} exceeded its memory limit and was OOM killed. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
        - alert: PodsUnavailable
          expr: kube_deployment_status_replicas_unavailable > 0 OR kube_daemonset_status_number_unavailable > 0
          for: 15m
          labels:
            severity: warning
          annotations:
            description: 'One or more pods are unavialable in a deployment or daemonset. Check that the deployment/daemonset spec is correct and that the application is working. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
        - alert: HPAMaxReplicasReached
          expr: kube_hpa_status_current_replicas == kube_hpa_spec_max_replicas and kube_hpa_spec_max_replicas != kube_hpa_spec_min_replicas
          for: 5m
          labels:
            severity: warning
          annotations:
            description: 'HPA has reached its maximum number of replicas. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
    - name: "Volume metrics"
      rules:
        - alert: PVCLowFreeStorageSpace
          expr: kubelet_volume_stats_available_bytes / kubelet_volume_stats_capacity_bytes < 0.1
          for: 5m
          labels:
            severity: critical
          annotations:
            description: 'A PVC has less than 10% free space remaining. Consider expanding the disk. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
    - name: "KubeAPI"
      rules:
        - alert: KubeAPI5XX
          expr: rate(apiserver_request_count{code=~"^(?:5..)$"}[5m])  > 1
          for: 5m
          labels:
            severity: critical
          annotations:
              description: "Kubernetes API Server is responding with 5XX errors. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>"
    - name: "SSL Certificate Expiry"
      rules:
        - alert: SSLExpiry
          expr: nginx_ingress_controller_ssl_expire_time_seconds - time() < 1209600
          for: 15m
          labels:
            severity: critical
          annotations:
              description: "Your certificate will expire in 14 days. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>"
    - name: "Grafana status"
      rules:
      - alert: NoGrafanaDashboardsAvailable
        expr: kube_pod_status_ready{pod=~"grafana.*",condition="true"} == 0 or absent(kube_pod_status_ready{pod=~"grafana.*",condition="true"})
        for: 5m
        labels:
          severity: critical
        annotations:
          description: 'Grafana dashboard is unavailable. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
    - name: "Nodes metrics"
      rules:
        - record: node_cpu_counts
          expr: count(node_cpu_seconds_total{mode="system"}) by(instance)
        - alert: NodeInodesFree
          expr: (node_filesystem_files_free /node_filesystem_files) * 100 < 20
          for: 5m
          labels:
            severity: critical
          annotations:
            description: 'Less than 20% of inodes are free on this node: {{ $labels.__meta_kubernetes_node_name }}. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
        - alert: NodeHighLoadAverage
          expr: sum(node_load1) by(instance) / node_cpu_counts > 0.95
          for: 10m
          labels:
            severity: critical
          annotations:
              description: 'Load average on this node is greater than 0.95. Check if autoscaler is working for this cluster. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
        - alert: NodeOOMKill
          expr: node_vmstat_oom_kill - node_vmstat_oom_kill offset 5m > 0
          for: 1m
          labels:
            severity: critical
          annotations:
            description: 'A node had a process exceeded its memory limit and was OOM killed. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
        - alert: NodeHighMemUsageWarning
          expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.2 and node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes > 0.1
          for: 5m
          labels:
            severity: warning
          annotations:
            description: 'Less than 20% of memory is available on this node: {{ $labels.kubernetes_node }}. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
        - alert: NodeHighMemUsage
          expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.1
          for: 5m
          labels:
            severity: critical
          annotations:
            description: 'Less than 10% of memory is available on this node: {{ $labels.kubernetes_node }}. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
        - alert: NodeDiskSpaceFree
          expr: node_filesystem_free_bytes / node_filesystem_size_bytes < 0.05
          for: 5m
          labels:
            severity: critical
          annotations:
            description: 'Less than 5% of disk space remaining on this node: {{ $labels.kubernetes_node }}. Does you node require more disk space? <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
        - alert: NodeDiskSpaceFreeWarning
          expr: node_filesystem_free_bytes / node_filesystem_size_bytes < 0.1 and node_filesystem_free_bytes / node_filesystem_size_bytes > 0.05
          for: 5m
          labels:
            severity: warning
          annotations:
              description: 'Less than 10% of disk space remaining on this node: {{ $labels.kubernetes_node }}. Does you node require more disk space? <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
        - alert: NodeNotReady
          expr: kube_node_status_condition{condition="Ready",status="true"} == 0
          for: 5m
          labels:
            severity: critical
          annotations:
            description: 'Node: {{ $labels.kubernetes_node}}, has not been in a "Ready" state in Kubernetes for over 10 minutes. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
        - alert: NodeCpuHigh
          expr: (1 - rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100 > 90.0
          for: 5m
          labels:
            severity: critical
          annotations:
            description: 'CPU usage is Higher than 90% for over 10 minutes on this node: {{ $labels.kubernetes_node }}. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
    - name: "Autoscaling metrics"
      rules:
        - alert: AutoscalingMinNodes
          expr: count(kube_node_status_condition{condition="Ready",status="true"} == 1) < 3
          for: 5m
          labels:
            severity: critical
          annotations:
              description: 'Less than 3 nodes are available in your cluster. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
        - alert: AutoscalingMaxNodes
          expr: aws_autoscaling_group_desired_capacity_maximum{auto_scaling_group_name!~"^master-ca-central.*$"} == aws_autoscaling_group_max_size_maximum{auto_scaling_group_name!~"^master-ca-central.*$"}
          for: 5m
          labels:
            severity: critical
          annotations:
            description: 'Maximum number of nodes reached in autoscaling group. Consider increasing the maximum number of nodes in the autoscaling group and cluster autoscaler. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
        - alert: AutoscalingTooManyNodesCreated
          expr: count(time() - kube_node_created < 3600) > 5
          for: 5m
          labels:
            severity: warning
          annotations:
            description: 'More than 5 unique nodes were created in the last hour in your cluster. Make sure that the autoscaler is functioning correctly. <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
        - alert: AutoscalingUnhealthyCluster
          expr: cluster_autoscaler_cluster_safe_to_autoscale == 0
          for: 5m
          labels:
            severity: critical
          annotations:
            description: 'Cluster is not healthy enough for autoscaling! Are there a lot of non-ready nodes? <https://vmfarms.gitbook.io/customer-docs/alert-manual/alerts-index|Documentation>'
    ${var.prometheus_alerts_rules_extra}
EOF
}
