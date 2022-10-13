* There are specific `objectClass` entries that can be chained (they need to be in correct order)
* Each `objectClass` "attaches" some attributes to the entry. Extra attributes are not allowed besides the ones that have been attaches by object classes
* You don't need to add password in the ldif file itself, it can be later assign to the user by using `ldappasswrd` command
* Inside the container itself password for admin can be found in env var called `LDAP_ADMIN_PASSWORD`. Outside the container it can be found in secret called `openldap` under the same env var name


# Useful commands:

## Notable flags breakdown

1. -x -W
Do "basic" authentication and ask for password. Using -w allows to type the password as an argument instead

2. -D "cn=admin,dc=marketcircle,dc=com"

Run whatever you are running as a user you specified. In this case admin.

3. -b "dc=marketcircle,dc=com"

Specify "area" where to do commands. From my experience this is usually the same, as we are having very simple setup

4. -f denys.ldif

Use file `denys.ldif` as an input. Likely used for creating entries as files contain required info

5. -H ldapi://localhost

Specify host of where ldap server is running. If you are executing commands in openldap container itself no need to specify this

6. -LLL

Strip commenst and show structured output. Useful for feeding results to a script or a pipe, or to avoid "noisy" output

7. -Z

If TLS is required add this flag to start TLS request

## Show available object classes

Using admin user for authentication. Note this outputs a lot of information, but it has information about name of the object class, required attributes (`MUST`), optional attributes (`MAY`)

```
ldapsearch -D "cn=admin,dc=marketcircle,dc=com" -x -W -s base -b cn=Subschema objectClasses
```

## Show entries

Show entries (seems to be all) under `dc=marketcircle,dc=com` by using user specified in -D

```
ldapsearch -x -W -b "dc=marketcircle,dc=com" -D "cn=admin,dc=marketcircle,dc=com"
```

## Set a password

Password `jesus` to user `uid=denys,dc=marketcircle,dc=com` by using your user `cn=admin,dc=marketcircle,dc=com`

```
ldappasswd -s jesus -W -D "cn=admin,dc=marketcircle,dc=com" -x "uid=denys,dc=marketcircle,dc=com"
```

## Add user

Add user based on file `denys.ldif` and authenticate with admin user

```
ldapadd -c -x -W -D "cn=admin,dc=marketcircle,dc=com" -f denys.ldif
```
