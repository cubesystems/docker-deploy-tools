if [[ -z "${VAULT_ADDR}" ]]; then
    echo "\$VAULT_ADDR environment variable not defined"
  return 1
fi

if [[ -z "${VAULT_ID_TOKEN}" ]]; then
    echo "\$VAULT_ID_TOKEN environment variable not defined"
  return 1
fi

if [[ -z "${VAULT_JWT_ROLE}" ]]; then
    echo "${VAULT_JWT_ROLE} environment variable not defined"
  return 1
fi

# Login to Vault and get the client token
response=$(curl -sfS --request POST \
    --data "{\"role\": \"${VAULT_JWT_ROLE}\", \"jwt\": \"${VAULT_ID_TOKEN}\"}" \
    "${VAULT_ADDR}/v1/auth/jwt/login")

# Extract the token from the response using jq (ensure jq is installed)
VAULT_TOKEN=$(echo $response | jq -r .auth.client_token)

if [ ! -z "$VAULT_SECRETS" ]; then
  echo "Loading secrets from vault"

  while read -r line; do
    # Decode the JSON line
    decoded_line=$(echo "$line" | base64 -d)

    # Extract the key (env var name) and value (Vault path and field)
    env_var_name=$(echo "$decoded_line" | jq -r '.key')
    vault_path_field=$(echo "$decoded_line" | jq -r '.value')

    # Split the Vault path and field based on the '@' delimiter
    vault_path=$(echo "$vault_path_field" | cut -d'@' -f1)
    vault_field=$(echo "$vault_path_field" | cut -d'@' -f2)

    # Retrieve the secret and extract the field for KV version 2
    response=$(curl -sfS -H "X-Vault-Token: $VAULT_TOKEN" \
        "${VAULT_ADDR}/v1/kv/data/${vault_path}")

    # Extract the field using jq (for KV v2, the data is nested under data.data)
    secret_value=$(echo $response | jq -r ".data.data.${vault_field}")

    export "$env_var_name"="$secret_value"
  done < <(echo "$VAULT_SECRETS" | yq -o json | jq -r 'to_entries[] | @base64')
fi

# optionally, create ssh certificate
if [ ! -z "$VAULT_SSH_ROLE" ]; then
  echo "Loading ssh certificate from vault"

  key_type=ed25519
  key_path=${HOME}/.ssh/id_${key_type}
  public_key_path=${key_path}.pub
  cert_path=${key_path}-cert.pub

  mkdir -m 0700 -p ~/.ssh
  ssh-keygen -q -t ${key_type} -N "" -f $key_path

  public_key=$(cat "$public_key_path")

  response=$(curl -sfS --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
      --data "{\"public_key\": \"$public_key\"}" \
      "${VAULT_ADDR}/v1/ssh/sign/${VAULT_SSH_ROLE}")

  # Extract the signed SSH key using jq and save to file
  echo "$response" | jq -r '.data.signed_key' > "$cert_path"

  # Check if the signed key was successfully saved
  if [ -s "$cert_path" ]; then
      echo "SSH key successfully signed and saved to $cert_path"
  else
      echo "Failed to sign SSH key."
  fi
fi
