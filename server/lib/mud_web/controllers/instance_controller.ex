defmodule MudWeb.InstanceController do
  use MudWeb, :controller

  alias Mud.Engine.Instance

  require Logger

  def list_all(conn, _params) do
    instances = Instance.list_all()

    render(conn, "index.json", instances: instances)
  end

  def get_by_slug(conn, %{"instance" => slug}) do
    instance = Instance.get_by_slug!(slug)

    render(conn, "instance.json", instance: instance)
  end
end
