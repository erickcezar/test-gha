declare local var.credential STRING;
declare local var.username STRING;

set var.credential = if(req.http.Authorization ~ "^Basic (.*)$", re.group.1, "");
set var.username = if(digest.base64_decode(var.credential) ~ "^(.+?):.*$", re.group.1, "unknown");

if (digest.secure_is_equal(
  table.lookup(username_password, var.credential, "NOTFOUND"),
  "NOTFOUND"
)) {
  log "syslog :: Access denied for user " var.username;
  error 401 "Restricted";
}

log "syslog :: Access granted for user " var.username;

unset req.http.Authorization;
set req.http.Authorized-User = var.username;
