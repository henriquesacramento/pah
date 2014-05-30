in_root do
  append_to_file '.env', "SECRET_KEY_BASE: #{SecureRandom::hex(60)}\n"

  gsub_file 'config/secrets.yml', /secret_key_base: (.*)/, "secret_key_base: <%= ENV[\"SECRET_KEY_BASE\"] %>"
end

git add: 'config/secrets.yml'
git add: '.env'
git_commit 'Replace secret key base with environment variable.'