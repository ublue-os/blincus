key="${args[key]}"
if config_has_key "$key"; then
  config_get "$key"
else
  echo "No such key: $key"
fi