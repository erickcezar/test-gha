// if (resp.status == 404) {
//   # Right now this page reports a 400 rather than a 404,
//   # this might be due to this setup.
//   set req.url = "website-404-key";
//   return(restart);
// }

// if (req.url == "/404/") {
//   # The /404 page actually has a response code of 200
//   # so we are setting that to 404 to not confuse the browser
//   set resp.status = 404;
// }
