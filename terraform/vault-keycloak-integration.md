# Vault and Keycloak integration

Hashicorp Vault is an open-source tool to manage secrets and secret access.

Access to secrets is granted via group memberships and the corresponding policies. Despite you can manage users within Vault, in an enterprise context users are often managed centrally. MarketCircle is using an integration with the open source identity provider Keycloak with Vault.

## Configuring Keycloak

### Create a OIDC Client

OIDC is OpenID Connect, a standard built on top of the OAuth2.0 authorization framework. It's necessary to create to connect this Client ID with Vault (and other apps).

![image](https://user-images.githubusercontent.com/6879177/191780448-f0f3f55a-02eb-4884-8bd7-62ca9768a66b.png)

The following configs must be set:
- Standard Flow Enable: ```true```
- Access Type: ```Confidential```
- Valid Redirect URIs: The Vault URL. In dev it is: https://vault.marketcircle.dev/*

![image](https://user-images.githubusercontent.com/6879177/191780747-8004ad15-3d42-4470-b2f9-ec27768b097d.png)

After create and save the new OIDC Client, in on ```Credentials``` tab the Client Secret will be generated. We will use this secret in the next steps.

![image](https://user-images.githubusercontent.com/6879177/191780899-727ccf0c-a96c-499b-ac3f-4f5ee12ec0e9.png)


### Define Client roles

Define client roles, according to your use-case. In this example, we will have a ```management``` and a ```reader``` roles. But you can define your own roles and after correlate them with the Vault groups/policies.  
Go to OIDC Client -> Roles to define new roles.

![image](https://user-images.githubusercontent.com/6879177/191781150-662eade8-693b-4d9f-83ae-685494ed3cab.png)

You can define composite roles to avoid repite to create with the same properties Vault groups/policies.  
For example, the management role is composite with the reader role, so it's not necessary give management user read permissions.

![image](https://user-images.githubusercontent.com/6879177/191781440-f1d8337c-05b2-4dc9-8f3e-2c603ddf63c9.png)


### Add claims to Vault has access to the client roles

For the Vault to identify a role created in the Client ID and correlate with the existing group/policy in the Vault, we need to create a mapper allowing this information to be available in the authentication process.  
Go to OIDC Client -> Mappers and do the following steps:

![image](https://user-images.githubusercontent.com/6879177/191781589-ae76d4ba-b018-4074-8292-604841c14dc5.png)

- Create a new mapper
- The mapper type needs to be: ```User Client Role```
- Multivalued: ```true```
- Token Claim Name: Could be something like ```resource_access.${cliend_id}.roles```. It will be used in the next steps.

![image](https://user-images.githubusercontent.com/6879177/191781740-d99cbd14-05cb-4a52-bf1f-55744401620e.png)

### Define the client role to a user or group

User:

![image](https://user-images.githubusercontent.com/6879177/191783347-65115875-e71f-4bb9-aca3-b60b3a2fbc19.png)

Group:

![image](https://user-images.githubusercontent.com/6879177/191783199-7273c8f1-4485-463a-989a-a3a44afa59ca.png)


### ***All these steps need to be done manually (for now). In the future, We can change it to be done using Terraform***

## Configuring Vault

### ***All steps here needs to be done using Terraform***

### Create a key to sign each token
Vault will sign each token that is issued by the secrets engine. Hence we provide a key for our OIDC identity:

```
resource "vault_identity_oidc_key" "keycloak_provider_key" {
  name      = "keycloak"
  algorithm = "RS256"
}
```

### OIDC auth backend for Vault

We have to enable the OIDC auth backend for Vault. We will use the same vault in dev environment as an example.  
Here we will use the ```Client Secret``` that we created before and store it in the ```oidc_client_secret``` and store the ```Client ID``` in ```oidc_client_id```.  
Notice that ```oidc_discovery_url``` is the URL of Keycloak.

```
resource "vault_jwt_auth_backend" "keycloak" {
  path               = "oidc"
  type               = "oidc"
  default_role       = "default"
  oidc_discovery_url = "https://oauth-shared.marketcircle.dev/realms/master"
  oidc_client_id     = "vault-dev"
  oidc_client_secret = var.vault_dev_keycloak_secret

  tune {
    audit_non_hmac_request_keys  = []
    audit_non_hmac_response_keys = []
    default_lease_ttl            = "1h"
    listing_visibility           = "unauth"
    max_lease_ttl                = "1h"
    passthrough_request_headers  = []
    token_type                   = "default-service"
  }
}

```

### Define a backend role

Define a backend role to be used for authentication and to assign/ map permissions to a user. The identifier is used to create Vault entities on the fly when a user logs in via the OIDC method. Each entity can be enriched with some metadata from the token.  
To dynamically assign Vault policies for grants from Keycloak (claims), we have to tell Vault where the claims are listed in the idToken. We set this in the Keycloak preparation section to ```resource_access.${client_id}.roles```. Vault expects nested JSON attributes in JSON-Path syntax which means ```resource_access.${client_id}.roles``` in JSON Path notation becomes /resource_access/${client_id}/roles.

```
resource "vault_jwt_auth_backend_role" "default" {
  backend        = vault_jwt_auth_backend.keycloak.path
  role_name      = "default"
  role_type      = "oidc"
  token_ttl      = 3600
  token_max_ttl  = 3600

  bound_audiences = ["vault-dev"]
  user_claim      = "sub"
  claim_mappings = {
    preferred_username = "username"
    email              = "email"
  }

  allowed_redirect_uris = [
      "https://vault.marketcircle.dev/ui/vault/auth/oidc/oidc/callback",
      "https://vault.marketcircle.dev/oidc/callback"
  ]
  groups_claim = "/resource_access/vault-dev/roles"
}
```

### Create policies and groups

Our authentication backend in Vault is ready to use. Now we need to provide some policies and groups that Vault can actually grant permissions to resources. In this sample we have a ```management``` and a ```reader``` policy, where only the ```management``` policy grants write access to secrets. Note that we configured the ```management``` role on Keycloak as a composite role inheriting the ```reader``` role, hence we don’t have to grant read, list permissions in multiple policies.

Using the Terraform module ```terraform-kubernetes-vault-external-groups```, it will create policies, assign to groups and create external groups that will be a mapper to groups, managed from an external system, in that case, Keycloak.

```
module "reader" {
  source = "../modules/terraform-kubernetes-vault-external-groups"
  external_accessor = vault_jwt_auth_backend.keycloak.accessor
  vault_identity_oidc_key_name = vault_identity_oidc_key.keycloak_provider_key.name
  groups = [
    {
      group_name = "reader"
      rules = [
        {
          path         = "/secrets/*"
          capabilities = ["read", "list"]
        },
        {
          path         = "/aws/*"
          capabilities = ["read", "list"]
        }
      ]
    }
  ]
}

module "management" {
  source = "../modules/terraform-kubernetes-vault-external-groups"
  external_accessor = vault_jwt_auth_backend.keycloak.accessor
  vault_identity_oidc_key_name = vault_identity_oidc_key.keycloak_provider_key.name
  groups = [
    {
      group_name = "management"
      rules = [
        {
          path         = "/secrets/*"
          capabilities = ["create", "update", "delete"]
        },
        {
          path         = "/aws/*"
          capabilities = ["create", "update", "delete"]
        },
        {
          path = "mc-dev-cert-manager-cluster-issuer/*"
          capabilities = ["create", "read", "update", "delete", "list"]
        }
      ]
    }
  ]
}
```

### Explaining the ```terraform-kubernetes-vault-external-groups``` module

This module is responsible to create a policy, a role, a group and a connect to a external resource. The external resource is responsible to correlate
with the same role as Keycloak.

Example:

![image](https://user-images.githubusercontent.com/6879177/191786664-8d3a0cec-85f8-4582-bfca-133379db6ad9.png)

After creating the policies and groups, it will create an external resource. Here is the code in the module:

![image](https://user-images.githubusercontent.com/6879177/191787937-0cf4cef9-a805-491d-a1b0-0ce57831d271.png)

In this step, the relationship between the group created in the Vault and the group created in the Keycloak will be created, using the features of the keycloak backend configuration in the Vault.

### ***If you want to create specific roles to individual people, it's important to create this role on the OIDC Client, create a mapper and then define a group_name in Vault using the same role name as keycloak, using the terraform module with the specific permissions. The process will be the same as above***
