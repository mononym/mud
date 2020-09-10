defmodule MudWeb.InstanceController do
  use MudWeb, :controller

  alias Mud.Engine.Instance

  require Logger

  def list_all(conn, _params) do
    instances = Instance.list_all()

    render(conn, "index.json", instances: instances)
  end
end
