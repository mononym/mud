defmodule Mud.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    :ets.new(:session, [:named_table, :public, read_concurrency: true])

    # List all child processes to be supervised
    children = [
      {Phoenix.PubSub, name: Mud.PubSub},
      # Start the Ecto repository
      Mud.Repo,
      # Start the endpoint when the application starts
      MudWeb.Endpoint,
      # Session Cache
      {Redix, host: Application.get_env(:mud, :redis_endpoint), name: :redix},
      Mud.Vault,
      {Registry, keys: :unique, name: Mud.Engine.CharacterSessionRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: Mud.Engine.CharacterSessionSupervisor},
      {Task.Supervisor, name: Mud.TaskSupervisor},
      {Registry, keys: :unique, name: :scripts},
      {DynamicSupervisor, strategy: :one_for_one, name: Mud.Engine.ScriptSupervisor},
      Mud.Engine.System.Time,
      Mud.StoreManager
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mud.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MudWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
