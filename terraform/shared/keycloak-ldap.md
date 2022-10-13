# OpenLDAP and Keycloak DOC

## FAQ

### IMPORTANT

The version that must be used in the openldap image is 1.2.2.
Using other versions, LDAP fails to restart/recreate pods for some unknown reason. For safety, do not change the version.

### Why use LDAP and Keycloak?

To use a solution to centralize user management for different applications. LDAP will store the structure of users and groups, while Keycloak provides us with a friendly interface for management.

### Where are the LDAP and Keycloack admin passwords stored?

The keycloak admin password is set in the envs in terraform cloud, in the shared workspace.

The LDAP administrator password is generated at the time of installing helm charts. Here's the command to get the password:

`kubectl get secret openldap -o jsonpath="{.data.LDAP_ADMIN_PASSWORD}" | base64 --decode; echo`

### How does LDAP and keycloak integration work?

```
1. In User Federation tab, select ldap from the Add provider dropdown.
2. Provide the required LDAP configuration details
3. Select Synchronize All Users to see the list of users imported

Required LDAP configuration fields and values

- Edit Mode -> WRITABLE
- Sync Registrations -> On
- Vendor -> Others
- Connection URL -> The internal address to openldap pod/service: ldap://openldap.openldap.svc.cluster.local
- Users DN -> The full DN of the LDAP tree where your users are located. In our case: ou=People,dc=marketcircle,dc=com
- Bind DN -> DN of the administrative or service user that accesses the information to use. cn=admin,dc=marketcircle,dc=com
- Bind Credential -> LDAP Admin password
```

###  How can Keycloak be integrated with other applications?

As the keycloak needs to have a public URL, and it already has a security mechanism through tokens, we create an entry in Nginx ingress with the address:


`oauth-shared.marketcircle.dev`

### How to create configurations/tokens for new application integrations?

```
1. Go to admin console keycloak
2. Click clients
3. Create
4. Type the Client ID
5. Acess type -> confidential
6. Type the Root URL for the app. Ex: https://grafana-shared.marketcircle.dev
7. Save
8. After Save, go to Credentials and get the Client Authenticator secret.
```
### What URLs are used for SSO authentication?

Applications may vary in the way they work with parameters, but in general they will be these URLs:
```
auth_url: https://oauth-shared.marketcircle.dev/realms/master/protocol/openid-connect/auth
token_url: https://oauth-shared.marketcircle.dev/realms/master/protocol/openid-connect/token
api_url: https://oauth-shared.marketcircle.dev/realms/master/protocol/openid-connect/userinfo
```
The client id and secret that was generated in the previous step will also be used

### How does the backup routine work?

As we have Velero installed and running the backup routine on the pods and PVCs, we will have backups of the LDAP and Keycloak database
