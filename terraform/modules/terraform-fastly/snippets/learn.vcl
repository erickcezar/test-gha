if (req.url ~ "^/learn") {

  set req.backend = F_DigitalOcean_Spaces_Learn;

  if (!req.http.Fastly-SSL) {
    error 801 "Force SSL";
  }

  set req.http.host = "marketcircle-learn-beta.nyc3.digitaloceanspaces.com";

  if( req.url.path ~ "^/learn/?$" ) {
    set req.url = "/index.html";
    return(lookup);
  }

  if( req.url.path ~ "^/learn/table-of-contents[/]?$" ) {
    set req.url = "/toc.html";
    return(lookup);
  }

  if( req.url.path == "/learn/learn.json" ) {
    set req.url = "/learn.json";
    return(lookup);
  }

  if (req.url.path ~ "^/learn/assets/(.*)") {
    set req.backend = F_DigitalOcean_Spaces_Learn;
    set req.url = "/assets/" re.group.1;
    return(lookup);
  }

  if (req.url.path ~ "^/learn/([^/?]+)/?") {
    set req.backend = F_DigitalOcean_Spaces_Learn;
    set req.url = "/articles/" re.group.1 ".html";
    return(lookup);
  }
}
