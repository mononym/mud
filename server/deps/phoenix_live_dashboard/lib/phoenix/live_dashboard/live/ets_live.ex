defmodule Phoenix.LiveDashboard.EtsLive do
  use Phoenix.LiveDashboard.Web, :live_view
  import Phoenix.LiveDashboard.TableHelpers

  alias Phoenix.LiveDashboard.{SystemInfo, EtsInfoComponent}

  @sort_by ~w(size memory)
  @temporary_assigns [tables: [], total: 0]

  @impl true
  def mount(%{"node" => _} = params, session, socket) do
    {:ok, assign_defaults(socket, params, session, true), temporary_assigns: @temporary_assigns}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign_params(params, @sort_by)
     |> assign_ref(params)
     |> fetch_ets()}
  end

  defp fetch_ets(socket) do
    %{search: search, sort_by: sort_by, sort_dir: sort_dir, limit: limit} = socket.assigns.params

    {tables, total} =
      SystemInfo.fetch_ets(socket.assigns.menu.node, search, sort_by, sort_dir, limit)

    assign(socket, tables: tables, total: total)
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="tabular-page">
      <h5 class="card-title">ETS</h5>

      <div class="tabular-search">
        <form phx-change="search" phx-submit="search" class="form-inline">
          <div class="form-row align-items-center">
            <div class="col-auto">
              <input type="search" name="search" class="form-control form-control-sm" value="<%= @params.search %>" placeholder="Search by name" phx-debounce="300">
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
            tables out of <%= @total %>
          </div>
        </div>
      </form>

      <%= if @ref do %>
        <%= live_modal @socket, EtsInfoComponent,
          id: @ref,
          title: "ETS - #{inspect(@ref)}",
          node: @menu.node,
          return_to: self_path(@socket, @menu.node, @params),
          live_dashboard_path: &live_dashboard_path(@socket, &1, &2, &3, @params) %>
      <% end %>

      <div class="card tabular-card mb-4 mt-4">
        <div class="card-body p-0">
          <div class="dash-table-wrapper">
            <table class="table table-hover mt-0 dash-table clickable-rows">
              <thead>
                <tr>
                  <th class="pl-4">Name or module</th>
                  <th>Protection</th>
                  <th>Type</th>
                  <th>
                    <%= sort_link(@socket, @live_action, @menu, @params, :size, "Size") %>
                  </th>
                  <th>
                    <%= sort_link(@socket, @live_action, @menu, @params, :memory, "Memory") %>
                  </th>
                  <th>Owner</th>
                </tr>
              </thead>
              <tbody>
                <%= for table <- @tables, list_ref = encode_reference(table[:id]) do %>
                  <tr phx-click="show_info" phx-value-ref="<%= list_ref %>" phx-page-loading>
                    <td class="tabular-column-name pl-4"><%= table[:name] %></td>
                    <td><%= table[:protection] %></td>
                    <td><%= table[:type] %></td>
                    <td><%= table[:size] %></td>
                    <td><%= format_words(table[:memory]) %></td>
                    <td><%= inspect(table[:owner]) %></td>
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
    {:noreply, fetch_ets(socket)}
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

  def handle_event("show_info", %{"ref" => ref}, socket) do
    {:noreply,
     push_patch(socket,
       to: live_dashboard_path(socket, :ets, node(), [ref], socket.assigns.params)
     )}
  end

  defp self_path(socket, node, params) do
    live_dashboard_path(socket, :ets, node, [], params)
  end

  defp assign_ref(socket, %{"ref" => ref_param}) do
    assign(socket, ref: decode_reference(ref_param))
  end

  defp assign_ref(socket, %{}), do: assign(socket, ref: nil)
end
