defmodule MudWeb.Components do
  use Phoenix.Component
  use Phoenix.HTML

  def tooltip(assigns) do
    ~H"""
    <div class="tooltip opacity-100 z-50 select-none">
      <span id={"#{Map.get(assigns, :ref, UUID.uuid4())}-tooltip"} class={"tooltiptext opacity-100 z-50 #{Map.get(assigns, :class, "")}"}><%= assigns.text %></span>
    </div>
    """
  end
end
