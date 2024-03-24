if [[ -z "${VAULT_ADDR}" ]]; then
    echo "\$VAULT_ADDR environment variable not defined"
  return 1
fi

if [[ -z "${VAULT_ID_TOKEN}" ]]; then
    echo "\$VAULT_ID_TOKEN environment variable not defined"
  return 1
fi

if [[ -z "${VAULT_ROLE}" ]]; then
    echo "\$VAULT_ROLE environment variable not defined"
  return 1
fi

if [[ -z "${VAULT_SECRETS}" ]]; then
    echo "\$VAULT_SECRETS environment variable not defined"
  return 1
fi

export VAULT_TOKEN="$(vault write -field=token auth/jwt/login role=$VAULT_ROLE jwt=$VAULT_ID_TOKEN)"

while read -r line; do
  # Decode the JSON line
  decoded_line=$(echo "$line" | base64 -d)

  # Extract the key (env var name) and value (Vault path and field)
  env_var_name=$(echo "$decoded_line" | jq -r '.key')
  vault_path_field=$(echo "$decoded_line" | jq -r '.value')

  # Split the Vault path and field based on the '@' delimiter
  vault_path=$(echo "$vault_path_field" | cut -d'@' -f1)
  vault_field=$(echo "$vault_path_field" | cut -d'@' -f2)

  # Retrieve the secret value from Vault
  secret_value=$(vault kv get --field=$vault_field -mount=kv $vault_path)

  export "$env_var_name"="$secret_value"
done < <(echo "$VAULT_SECRETS" | yq -o json | jq -r 'to_entries[] | @base64')
