import Config

config :mud,
  signup_player_token_ttl: String.to_integer(System.get_env("SIGNUP_PLAYER_TOKEN_TTL", "604800")),
  email_format: Regex.compile!(System.get_env("EMAIL_FORMAT", "^.+@.+$")),
  email_max_length: String.to_integer(System.get_env("EMAIL_MAX_LENGTH", "254")),
  email_min_length: String.to_integer(System.get_env("EMAIL_MIN_LENGTH", "3")),
  login_token_ttl: String.to_integer(System.get_env("LOGIN_TOKEN_TTL", "900")),
  nickname_format: Regex.compile!(System.get_env("NICKNAME_FORMAT", "^[a-zA-Z0-9 ]+$")),
  nickname_max_length: String.to_integer(System.get_env("NICKNAME_MAX_LENGTH", "30")),
  nickname_min_length: String.to_integer(System.get_env("NICKNAME_MIN_LENGTH", "2")),
  no_reply_email_address: System.get_env("NO_REPLY_EMAIL_ADDRESS", "no-reply@unnamedmud.com"),
  character_context_buffer_trim_size:
    String.to_integer(System.get_env("CHARACTER_CONTEXT_BUFFER_TRIM_SIZE", "800")),
  character_context_buffer_max_size:
    String.to_integer(System.get_env("CHARACTER_CONTEXT_BUFFER_MAX_SIZE", "1200")),
  character_inactivity_timeout_warning:
    String.to_integer(System.get_env("CHARACTER_INACTIVITY_TIMEOUT_WARNING", "600000")),
  character_inactivity_timeout_final:
    String.to_integer(System.get_env("CHARACTER_INACTIVITY_TIMEOUT_FINAL", "720000")),
  create_player_token_ttl: String.to_integer(System.get_env("CREATE_PLAYER_TOKEN_TTL", "1800")),
  race_image_cf_domain:
    System.get_env(
      "AWS_RACE_IMAGE_CF_DOMAIN",
      "alpha.cluster-c3nd1btjw5ts.us-east-1.rds.amazonaws.com"
    )

config :mud, :ecwid,
  client_id: System.get_env("ECWID_CLIENT_ID"),
  client_secret: System.get_env("ECWID_CLIENT_SECRET"),
  public_token: System.get_env("ECWID_PUBLIC_TOKEN"),
  private_token: System.get_env("ECWID_PRIVATE_TOKEN")

if System.get_env("PHX_SERVER") && System.get_env("RELEASE_NAME") do
  config :mud, MudWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      Environment variable 'DATABASE_URL' is missing.
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :mud, Mud.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

    # The secret key base is used to sign/encrypt cookies and other secrets.
    # A default value is used in config/dev.exs and config/test.exs but you
    # want to use a different value for prod and you most likely don't want
    # to check this value into version control, so we use an environment
    # variable instead.
    secret_key_base =
      System.get_env("SECRET_KEY_BASE") ||
        raise """
        environment variable SECRET_KEY_BASE is missing.
        """

    host = System.get_env("PHX_HOST") || "echoesofanempire.com"
    port = String.to_integer(System.get_env("PORT") || "80")

    config :mud, MudWeb.Endpoint,
      url: [scheme: "https", host: host, port: 443],
      http: [
        # Enable IPv6 and bind on all interfaces.
        # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
        # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
        # for details about using IPv6 vs IPv4 and loopback vs public addresses.
        ip: {0, 0, 0, 0, 0, 0, 0, 0},
        port: port
      ],
      secret_key_base: secret_key_base

    postmark_api_token =
      System.get_env("POSTMARK_API_TOKEN") ||
        raise "POSTMARK_API_TOKEN not available"


  config :mud, Mud.Mailer,
  adapter: Swoosh.Adapters.Postmark,
  api_key: postmark_api_token

  app_name =
    System.get_env("FLY_APP_NAME") ||
      raise "FLY_APP_NAME not available"

  config :libcluster,
    debug: true,
    topologies: [
      fly6pn: [
        strategy: Cluster.Strategy.DNSPoll,
        config: [
          polling_interval: 5_000,
          query: "#{app_name}.internal",
          node_basename: app_name
        ]
      ]
    ]
end
