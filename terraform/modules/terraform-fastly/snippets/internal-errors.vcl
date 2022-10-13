if (obj.status == 600) {
  set obj.status = 302;
  set obj.http.Location = "https://www.marketcircle.dev/appcasts/releases/latest-daylite.zip";
  return(deliver);
}

if (obj.status == 601) {
  set obj.status = 301;
  set obj.http.Location = "https://www.marketcircle.dev/apidocs/" req.http.redirect;
  return(deliver);
}

if (obj.status == 602) {
  set obj.status = 301;
  set obj.http.Location = "https://www.marketcircle.dev/experts/" req.http.redirect;
  return(deliver);
}

if (obj.status == 603) {
  set obj.status = 308;
  set obj.http.Location = "https://www.marketcircle.dev" + table.lookup(mc_redirects, req.url);
  return(deliver);
}

if (obj.status == 604) {
  set obj.status = 308;
  set obj.http.Location = "https://support.marketcircle.com/hc/en-us" + table.lookup(zd_redirects, req.url);
  return(deliver);
}

if (obj.status == 605) {
  set obj.status = 308;
  set obj.http.Location = "https://download.marketcircle.com" + table.lookup(download_redirects, req.url);
  return(deliver);
}

if (obj.status == 606) {
  set obj.status = 301;
  set obj.http.Location = "https://status.marketcircle.com";
  return(deliver);
}

if (obj.status == 607) {
  set obj.status = 308;
  set obj.http.Location = "https://www.marketcircle.dev" + req.url;
  return(deliver);
}

if (obj.status == 608) {
  # Returns the Country code
  set obj.status = 200;
  set obj.http.Content-Type = "application/json";
  synthetic "{%22code%22: %22" + json.escape(client.geo.country_code) + "%22}";
  return(deliver);
}

if (obj.status == 609) {
  set obj.status = 308;
  set obj.http.Location = "http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSDate_Class/Reference/Reference.html";
  return(deliver);
}

if (obj.status == 610) {
  set obj.status = 308;
  set obj.http.Location = "https://marketcircle.as.me/trial-advisor";
  return(deliver);
}

if (obj.status == 612) {
  set obj.status = 308;
  set obj.http.Location = "https://download.marketcircle.com/Google-Ads.txt";
  return(deliver);
}

if (obj.status == 613) {
  set obj.status = 308;
  set obj.http.Location = "https://marketcircle.as.me/?appointmentType=18380174";
  return(deliver);
}

if (obj.status == 614) {
  set obj.status = 308;
  set obj.http.Location = "https://harmonizely.com";
  return(deliver);
}

if (obj.status == 615) {
  set obj.status = 308;
  set obj.http.Location = "https://app.harmonizely.com/connect/daylite";
  return(deliver);
}

if (obj.status == 618) {
  set obj.status = 308;
  set obj.http.Location = "https://marketcircle.as.me/iosbooking";
  return(deliver);
}

if (obj.status == 619) {
  set obj.status = 308;
  set obj.http.Location = "https://marketcircle.as.me/iosteams";
  return(deliver);
}

if (obj.status == 620) {
  set obj.status = 308;
  set obj.http.Location = "https://marketcircle.blog" + req.url;
  return(deliver);
}
