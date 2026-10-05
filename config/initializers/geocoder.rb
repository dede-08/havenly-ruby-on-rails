Geocoder.configure(
  lookup: :nominatim,
  use_https: true,
  http_headers: { "User-Agent" => "HavenlyApp/1.0 (admahven@havenly.com)" }
)