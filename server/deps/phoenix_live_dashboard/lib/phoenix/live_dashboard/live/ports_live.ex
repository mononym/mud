defmodule Phoenix.LiveDashboard.PortsLive do
  use Phoenix.LiveDashboard.Web, :live_view
  import Phoenix.LiveDashboard.TableHelpers

  alias Phoenix.LiveDashboard.{SystemInfo, PortInfoComponent}

  @sort_by ~w(output input)
  @temporary_assigns [ports: [], total: 0]

  @impl true
  def mount(%{"node" => _} = params, session, socket) do
    {:ok, assign_defaults(socket, params, session, true), temporary_assigns: @temporary_assigns}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign_params(params, @sort_by)
     |> assign_port(params)
     |> fetch_ports()}
  end

  defp fetch_ports(socket) do
    %{search: search, sort_by: sort_by, sort_dir: sort_dir, limit: limit} = socket.assigns.params

    {ports, count} =
      SystemInfo.fetch_ports(socket.assigns.menu.node, search, sort_by, sort_dir, limit)

    assign(socket, ports: ports, total: count)
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="tabular-page">
      <h5 class="card-title">Ports</h5>

      <div class="tabular-search">
        <form phx-change="search" phx-submit="search" class="form-inline">
          <div class="form-row align-items-center">
            <div class="col-auto">
              <input type="search" name="search" class="form-control form-control-sm" value="<%= @params.search %>" placeholder="Search by name or port" phx-debounce="300">
            </div>
          </div>
        </form>
      </div>

      <form phx-change="select_limit" class="form-inline">
        <div class="form-row align-items-center">
          <div class="col-auto">Showing at most</div>
          <div class="col-auto">
            <div class="input-group input-group-sm">
              <select name="limit" class="custom-select" id="limit-select">
                <%= options_for_select(limit_options(), @params.limit) %>
              </select>
            </div>
          </div>
          <div class="col-auto">
            ports out of <%= @total %>
          </div>
        </div>
      </form>

      <%= if @port do %>
        <%= live_modal @socket, PortInfoComponent,
          port: @port,
          title: inspect(@port),
          return_to: self_path(@socket, @menu.node, @params),
          live_dashboard_path: &live_dashboard_path(@socket, &1, &2, &3, @params) %>
      <% end %>

      <div class="card table-card mb-4 mt-4">
        <div class="card-body p-0">
          <div class="dash-table-wrapper">
            <table class="table table-hover mt-0 dash-table clickable-rows">
              <thead>
                <tr>
                  <th class="pl-4">Port</th>
                  <th>Name or path</th>
                  <th>OS pid</td>
                  <th>
                    <%= sort_link(@socket, @live_action, @menu, @params, :input, "Input") %>
                  </th>
                  <th>
                    <%= sort_link(@socket, @live_action, @menu, @params, :output, "Output") %>
                  </th>
                  <th>Id</th>
                  <th>Owner</td>
                </tr>
              </thead>
              <tbody>
                <%= for port <- @ports, port_num = encode_port(port[:port]) do %>
                  <tr phx-click="show_info" phx-value-port="<%= port_num %>" phx-page-loading class="<%= row_class(port, @port) %>">
                    <td class="tabular-column-name pl-4"><%= port_num %></td>
                    <td class="w-50"><%= port[:name] %></td>
                    <td>
                      <%= if port[:os_pid] != :undefined do %>
                        <%= port[:os_pid] %>
                      <% end %>
                    </td>
                    <td><%= format_bytes(port[:input]) %></td>
                    <td><%= format_bytes(port[:output]) %></td>
                    <td><%= port[:id] %></td>
                    <td><%= inspect(port[:connected]) %></td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_info({:node_redirect, node}, socket) do
    {:noreply, push_redirect(socket, to: self_path(socket, node, socket.assigns.params))}
  end

  def handle_info(:refresh, socket) do
    if port = socket.assigns.port, do: send_update(PortInfoComponent, id: port)
    {:noreply, fetch_ports(socket)}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    %{menu: menu, params: params} = socket.assigns
    {:noreply, push_patch(socket, to: self_path(socket, menu.node, %{params | search: search}))}
  end

  def handle_event("select_limit", %{"limit" => limit}, socket) do
    %{menu: menu, params: params} = socket.assigns
    {:noreply, push_patch(socket, to: self_path(socket, menu.node, %{params | limit: limit}))}
  end

  def handle_event("show_info", %{"port" => port}, socket) do
    to = live_dashboard_path(socket, :ports, node(), [port], socket.assigns.params)
    {:noreply, push_patch(socket, to: to)}
  end

  defp self_path(socket, node, params) do
    live_dashboard_path(socket, :ports, node, [], params)
  end

  defp assign_port(socket, %{"port" => port_param}) do
    assign(socket, port: decode_port(port_param))
  end

  defp assign_port(socket, %{}), do: assign(socket, port: nil)

  defp row_class(port_info, active_port) do
    if port_info[:port] == active_port, do: "active", else: ""
  end
end
