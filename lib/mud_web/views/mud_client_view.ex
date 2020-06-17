defmodule MudWeb.MudClientView do
  use MudWeb, :view

  def recurse_inventory_items(items, item_index, myself) do
    for item <- items do
      children? = Map.has_key?(item_index, item.id)

      if children? do
        content_tag(:div, class: "flex flex-col") do
          content_tag(:div, class: "cursor-pointer select-none pl-4 hover:bg-gray-800") do
            content_tag(:p) do
              [
                content_tag(:i, [
                  {:class,
                   "fas fa-#{
                     if true do
                       "box-open"
                     else
                       "box"
                     end
                   }"}
                ]) do
                end,
                content_tag(:span) do
                  " "
                end,
                content_tag(:i, [
                  {:"phx-click", "toggle_container"},
                  {:"phx-target", myself},
                  {:class,
                   "fas fa-#{
                     if true do
                       "minus"
                     else
                       "plus"
                     end
                   }-circle"}
                ]) do
                end,
                content_tag(:span) do
                  " #{item.text}"
                end
              ]
            end
          end
        end
      else
        content_tag(:div) do
          "boo"
        end
      end
    end
  end
end
