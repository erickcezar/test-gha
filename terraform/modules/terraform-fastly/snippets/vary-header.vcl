if (req.url ~ "^/assets/style/style.css(\?.*)?$") {
  set resp.http.Vary = "*";
}