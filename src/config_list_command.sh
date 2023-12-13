for key in $(config_keys); do
  echo "$key: $(config_get "$key")"
done