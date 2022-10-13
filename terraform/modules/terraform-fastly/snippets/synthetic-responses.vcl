
if (req.url == "/downloads/latest-daylite") {
  error 600 "Fastly Internal";
}

if (req.url ~ "/daylite/apidocs/(.*)") {
  set req.http.redirect = re.group.1;
  error 601 "Fastly Internal";
}

if (req.url ~ "/help/experts/(.*)") {
  set req.http.redirect = re.group.1;
  error 602 "Fastly Internal";
}

if (req.url == "/status" || req.url == "/status/") {
  error 606 "Fastly Internal";
}

if (req.http.host == "marketcircle.com") {
  error 607 "Fastly Internal";
}

if (req.url ~ "/redirects/mcr/(.*)" || req.url ~ "/redirects/mcr") {
  error 609 "Fastly Internal";
}

if (req.url ~ "/daylite/app/onboarding-call(/|$)") {
  error 610 "Fastly Internal";
}

if (req.url.basename == "Google-Ads.txt") {
  error 612 "Fastly Internal";
}

if (req.url ~ "/daylite/app/schedule-onboarding-call(/|$)") {
  error 613 "Fastly Internal";
}

if (req.url ~ "/daylite/app/harmonizely-learn-more(/|$)") {
  error 614 "Fastly Internal";
}

if (req.url ~ "/learn/watch/(.*)") {
  if (re.group.1 == "?vid=125678059&title=Billings+Pro+Time+Tracking") {
    error 616 "Fastly Internal";
  }
    
  if (re.group.1 == "?vid=125685036&title=Billings+Pro+Interface+Tour") {
    error 617 "Fastly Internal";
  }
  
}

if (req.url ~ "/daylite/app/harmonizely-connect-account(/|$)") {
  error 615 "Fastly Internal";
}

if (req.url ~ "/daylite/app/schedule-onboarding-call-ios(/|$)") {
  error 618 "Fastly Internal";
}

if (req.url ~ "/daylite/app/schedule-onboarding-call-team-email(/|$)") {
  error 619 "Fastly Internal";
}

if (req.url ~ "/blog(/|$)(.*)") {
  set req.url = re.group.1 + re.group.2;
  error 620 "Fastly Internal";
}

