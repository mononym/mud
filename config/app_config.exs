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
  no_reply_email_address: System.get_env("NO_REPLY_EMAIL_ADDRESS", "no-reply@mud")

config :mud, :generators,
  migration: true,
  binary_id: true