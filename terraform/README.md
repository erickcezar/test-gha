# Terraform manifests for Cloud Deployment

Terraform is responsible to manage the entire lifecycle of infrastructure using infrastructure as code. That means declaring infrastructure components in configuration files that are then used by Terraform to provision, adjust and tear down infrastructure in various cloud providers.

This Project uses the following Terraform Providers:

- DigitalOcean
- kubernetes
- Helm

The "modules" folder contains personalized resources for this specific project.
Other modules are downloaded from public and private registries.

Each other folder contains Terraform resource definitions for each environment.

- Development - For Marketcircle's Development environment

In each environment, the locals.tf contains variables internal do the Project.
The variables.tf file, on the other hand, expose this variables externally
(usually defined on Terraform Cloud workspace).
