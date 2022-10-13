if (!req.http.Fastly-SSL) {
  error 801 "Force SSL";
}
if (table.lookup(mc_redirects, req.url)) {
  error 603 "Fastly Internal";
}
elsif (table.lookup(zd_redirects, req.url)) {
  error 604 "Fastly Internal";
}
elsif (table.lookup(download_redirects, req.url)) {
  error 605 "Fastly Internal";
}
