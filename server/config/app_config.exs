use Mix.Config

config :mud,
  signup_player_token_ttl: String.to_integer(System.get_env("SIGNUP_PLAYER_TOKEN_TTL", "604800")),
  email_format: Regex.compile!(System.get_env("EMAIL_FORMAT", "^.+@.+$")),
  email_max_length: String.to_integer(System.get_env("EMAIL_MAX_LENGTH", "254")),
  email_min_length: String.to_integer(System.get_env("EMAIL_MIN_LENGTH", "3")),
  login_token_ttl: String.to_integer(System.get_env("LOGIN_TOKEN_TTL", "900")),
  nickname_format: Regex.compile!(System.get_env("NICKNAME_FORMAT", "^[a-zA-Z0-9 ]+$")),
  nickname_max_length: String.to_integer(System.get_env("NICKNAME_MAX_LENGTH", "30")),
  nickname_min_length: String.to_integer(System.get_env("NICKNAME_MIN_LENGTH", "2")),
  no_reply_email_address: System.get_env("NO_REPLY_EMAIL_ADDRESS", "no-reply@mud"),
  character_context_buffer_trim_size:
    String.to_integer(System.get_env("CHARACTER_CONTEXT_BUFFER_TRIM_SIZE", "800")),
  character_context_buffer_max_size:
    String.to_integer(System.get_env("CHARACTER_CONTEXT_BUFFER_MAX_SIZE", "1200")),
  character_inactivity_timeout_warning:
    String.to_integer(System.get_env("CHARACTER_INACTIVITY_TIMEOUT_WARNING", "600000")),
  character_inactivity_timeout_final:
    String.to_integer(System.get_env("CHARACTER_INACTIVITY_TIMEOUT_FINAL", "1200000")),
  create_player_token_ttl: String.to_integer(System.get_env("CREATE_PLAYER_TOKEN_TTL", "1800")),
  race_image_cf_domain: System.get_env("AWS_RACE_IMAGE_CF_DOMAIN")

config :mud, :generators,
  migration: true,
  binary_id: true

config :ex_aws,
  normalize_path: false,
  region: {:system, "AWS_REGION"}

config :ex_aws, :hackney_opts, recv_timeout: 30_000
