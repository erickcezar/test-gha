if (req.backend == F_mc_corona_static_dev) {
  set beresp.http.Surrogate-Key = "corona";
}

if (req.backend == F_DigitalOcean_Spaces_Learn) {
  set beresp.http.Surrogate-Key = "learn";
}
