# Addons - Addons for DOKS

## Features

* External-DNS for DNSimple integration (Terraform will manage the DSN Entry for the external nginx LB IP)
* LoadBalancer for kubernetes (disable by default. The servicetype = loadbalancer should create an LB automatically)
* Metrics Server for monitoring
* NeutralData route
* Nginx Ingress Controller
* Kubernetes Storage Class with DigitalOcean integration



## Nginx ingress controller hack (IMPORTANT)

By default, until the last version, nginx ingress-controller does not support SSL over TCP.
It is possible, however, to workaround this limitation by tweaking the nginx "template".

IMPORTANT: This is not supported by the current nginx releases and may cause crashes during upgrades if the nginx.tmpl file changed. This hack was based on https://github.com/kubernetes/ingress-nginx/issues/636#issuecomment-749026036

1. Enable the hack in Terraform by "hack_ingress_nginx_enabled = true".

2. Set the tcp ports that should be exposed externally over SSL/TCP and the service:port that it should be routed.

3. Set the "default_ssl_certificate" secret file that SSL will serve on those ports. If not set, the default "fake certificate" will be used. Note that this is the secret containing the certificate. This means that in the first run of terraform (bootstrap) this secret will not exists. The ingress will be installed properly but, it will still use the fake one. Deploy the certificate (manually or using vault-secrets-operator) secret and then run the terraform apply again.

FOR UPGRADES: Before making upgrades in the ingress controller, check the nginx.tmpl file of the new version with the one in files/nginx.tmpl. The important lines are those after # TCP Services. Update the file properly and then make the upgrade.
