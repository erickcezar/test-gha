# terraform-kubernetes-cert-manager

cert-manager issues certificates for a cluster from the Let's Encrypt certificate authority.
cert-manager performs all tasks including 
issuing certificates, HTTP validation, renewing them periodically, 
and putting certificates in K8s secrets.

After cert-manager has been installed with Terraform you need to setup issuers manualy.
https://docs.cert-manager.io/en/latest/reference/issuers.html

For manual steps, refer to the docs here:
https://vmfarms.gitbook.io/customer-docs/tasks/networking/how-to-create-certificate

Remember to:

- Disable cloudflare SSL protection on the domain(s) that the certificate needs to be issued for if using "full + strict" TLS mode before isuing certificates for the first time.
- Use NLB to load balance on TCP layer and then configure the SSL-termination and force SSL redirect on the ingress resources.

## Upgrading to v0.4.x/v1.x from v0.3.x

Upgrading to version 1.0.0 (or 0.4.0) will require completing the upgrade process
for certmanager 0.10 -> 0.11 manually (https://cert-manager.io/docs/installation/upgrading/upgrading-0.10-0.11/).
The steps are summarized here:

```
# take a backup of the current cert-manager resources
kubectl get -o yaml -A issuer,clusterissuer,certificates,certificaterequests > cert-manager-backup.yaml

# delete the current cert-manager installation via helm
helm delete --purge cert-manager

# delete all cert-manager CRDs
kubectl get crds | grep certmanager  # get list of crds that must be deleted
kubectl delete crd CRD_NAME

# taint the crd apply resource
terraform taint module.cert-manager.null_resource.apply_cert_manager_crd

# increment cert-manager version to 1.x in your terraform config and install the new version
terraform apply

# upgrade the cert-manager annotations and restore on to cluster
sed 's/certmanager.k8s.io\/v1alpha1/cert-manager.io\/v1alpha2/g' cert-manager-backup.yaml > cert-manager-upgrade.yaml
kubectl apply -f cert-manager-upgrade.yaml

# edit any ingresses and update the cert-manager annotations from
# "certmananager.k8s.io/cluster-issuer" to "cert-manager.io/cluster-issuer".
# apply the new version of the ingresses using "kubectl apply"
```

This upgrade process does not involve downtime or disruption to existing certificates
(the certificates will continue to be served from existing secrets),
this merely updates the certificate renewal system.

