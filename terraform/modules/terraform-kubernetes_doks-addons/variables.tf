variable "vpc_uuid" {
  description = "The ID of the VPC where the Kubernetes cluster will be located."
  type        = string
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "region" {
  type        = string
  description = "The location of the cluster"
}


##########################################################################
# LoadBalancer

variable "enable_lb" {
  type        = bool
  description = "Wheather to create or not a static LB"
  default     = true
}

variable "lb_http_target_port" {
  description = "Loadbalancer internal HTTP port"
  default     = 30080
}

variable "lb_https_target_port" {
  description = "Loadbalancer internal HTTPS port"
  default     = 30443
}

variable "lb_size" {
  description = "The size of the Load Balancer. It must be either lb-small, lb-medium, or lb-large"
  default     = "lb-small"
}

variable "lb_size_unit" {
  type = number
  description = "Specifies the number of nodes to create the load balancer with"
  default     = 1
}

variable "lb_dest_tag" {
  description = "tag used by destination droplets to route LB traffic"
}

############################################################################
# ingress nginx

variable "nginx_enabled" {
  type = bool
  description = "Boolean to determine whether to install nginx"
  default = false
}

variable "nginx_release_name" {
  type        = string
  default     = "ingress-nginx"
  description = "Name of ingress controller helm release to create."
}

variable "nginx_version" {
  type        = string
  default     = "3.7.0"
  description = "Version of Ingress-nginx helm chart"
}

variable "nginx_namespace" {
  type        = string
  description = "Namespace to deploy nginx controller in"
  default     = "ingress-nginx"
}

variable "ingress_class" {
  type        = string
  default     = "nginx"
  description = <<EOF
  The name of the ingress class to create. Kubernetes ingresses can be assigned
  to this ingress controller/ingress class by setting the annotation
  kubernetes.io/ingress.class: 'controller name.
  Ingress objects without an ingress class will be assigned
  to the default 'nginx' ingress controller.
  More info at: https://kubernetes.github.io/ingress-nginx/user-guide/multiple-ingress/
  EOF
}

variable "enable_marketcircle_accesslogging_vars" {
  type        = bool
  default     = false
  description = "Enable Marketcircle access logging variables"
}

variable "proxy_protocol_enabled" {
  type        = bool
  default     = false
  description = "Whether proxy protocol is enabled in the ALB/NLB itself and the corresponding nginx-ingress-controller."
}
variable "max_nginx_replicas" {
  type        = number
  default     = 20
  description = "Maximum number of the pods in nginx controller autoscaler."
}

variable "min_nginx_replicas" {
  type        = number
  default     = 3
  description = "Minimum number of the pods in nginx controller autoscaler."
}

variable "additional_controller_config" {
  type        = map(string)
  default     = {}
  description = "Additional configuration to be attached to the nginx load balancer"
}

variable "pod_lifecycle" {
  description = "A map of nginx ingress controller container lifecycle"
  type        = string
  default     = ""
}

variable "termination_graceful_period_seconds" {
  description = "Nginx ingress controller container terminationGracefulPeriodSeconds"
  type        = number
  default     = 60
}

variable "resource_requests_cpu" {
  description = "CPU resource request for Nginx-ingress pods"
  type        = string
  default     = "500m"
}

variable "resource_requests_memory" {
  description = "Memory resource request for Nginx-ingress pods"
  type        = string
  default     = "512Mi"
}

variable "resource_limits_cpu" {
  description = "CPU resource limit for Nginx pods"
  type        = string
  default     = "1"
}

variable "resource_limits_memory" {
  description = "Memory resource limit for Nginx pods"
  type        = string
  default     = "1024Mi"
}

variable "use_daemonset" {
  description = "Deploy ingress-nginx as daemonset or deployment"
  type        = bool
  default     = true
}

variable "hack_ingress_nginx_enabled" {
  description = "Enable the hack to support SSL over TCP in ingress-nginx"
  type = bool
  default = false
}

variable "hack_tcp_ports" {
  type        = map(string)
  default     = {}
  description = "tcp ports that will be exposed thru SSL over TCP"
}

variable "default_ssl_certificate" {
  type        = string
  default     = ""
  description = "Points to the secret that should contains the default certificate"
}
#############################################################
## NeutralData

variable "neutraldata_route_enabled" {
  type        = bool
  default     = false
  description = "Enable NeutralData route"
}

variable "registry_server" {
  description = "url of registry server for pulling images"
  type        = string
}

variable "registry_username" {
  description = "Username for the registry server"
  type        = string
  sensitive   = true
}

variable "registry_password" {
  description = "password for the registry server"
  type        = string
  sensitive   = true
}

variable "neutraldata_route_image" {
  description = "image used by neutraldata route patch"
  type        = string
}

variable "neutraldata_route_args" {
  description = "argument to pass to the container"
  type        = list(any)
}

variable "neutraldata_tolerations" {
  description = "Tolerations for the daemonset"
  type        = list(map(string))
}

variable "externaldns_token" {
  description = "Token for External DNS manage the DNS provider"
  type        = string
  sensitive   = true
  default     = ""
}

variable "externaldns_account_id" {
  description = "Account ID for External DNS manage the DNS provider DNSimple"
  type        = string
  sensitive   = true
  default     = ""
}

variable "externaldns_zone" {
  description = "Zone for External DNS"
  type        = string
  default     = ""
}

############################################################################
# istio


variable "istio_enabled" {
  type = bool
  description = "Boolean to determine whether to install Istio"
  default = false
}

variable "istio_ingress_enabled" {
  type = bool
  description = "Boolean to determine whether to enable Istio Ingress"
  default = false
}

variable "istio_namespace" {
  type        = string
  description = "Namespace to deploy istio & kiali"
  default     = "istio-system"
}

variable "kiali_operator_namespace" {
  type        = string
  description = "Namespace to deploy kiali-operator"
  default     = "kiali-operator"
}
