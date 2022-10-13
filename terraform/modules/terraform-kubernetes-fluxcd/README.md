# FluxCD

* Flux is a tool for keeping Kubernetes clusters in sync with sources of configuration (like Git repositories), and automating updates to configuration when there is new code to deploy.
* This Terraform module is responsible to install Flux in a kubernetes cluster and set its configuration pointing to a GitHub repository. The GitHub respository must already exists. It is not managed by Terraform. By this, we prevent unintentional deletion of the repository.
* The GitHub repo can have the following structure (based on https://github.com/fluxcd/flux2-kustomize-helm-example):

```
├── apps
│   ├── base
│   ├── production
│   └── staging
├── infrastructure
│   ├── nginx
│   ├── redis
│   └── sources
└── clusters
    ├── production
    └── staging
```

* After the execution of this module, Flux will configure a "flux-system" folder under the cluster/<environment>, to store its own configuration. This config should not be touched because it is managed by Terraform. Any specfic customization on Flux deployment should be done by patching the Terraform resource (https://registry.terraform.io/providers/fluxcd/flux/latest/docs/guides/customize-flux).


Example usage of this module:

```
module "fluxcd" {
  source                = "../modules/terraform-kubernetes-fluxcd"
  github_owner          = "my-org"
  github_token          = "xxxxxxxxxxxxxxxxxxxxxxx"
  repository_name       = "cloud-infrastructure"
  repository_visibility = "private"
  branch                = "main"
  target_path           = "clusters/staging"
  environment           = "staging"
}
```
