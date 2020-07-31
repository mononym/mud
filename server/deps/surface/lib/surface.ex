defmodule Surface do
  @moduledoc """
  Surface is component based library for **Phoenix LiveView**.

  Built on top of the new `Phoenix.LiveComponent` API, Surface provides
  a more declarative way to express and use components in Phoenix.

  Full documentation and live examples can be found at [surface-demo.msaraiva.io](http://surface-demo.msaraiva.io)

  This module defines the `~H` sigil that should be used to translate Surface
  code into Phoenix templates.

  In order to have `~H` available for any Phoenix view, add the following import to your web
  file in `lib/my_app_web.ex`:

      # lib/my_app_web.ex

      ...

      def view do
        quote do
          ...
          import Surface
        end
      end

  ## Defining components

  To create a component you need to define a module and `use` one of the available component types:

    * `Surface.Component` - A stateless component.
    * `Surface.LiveComponent` - A live stateful component.
    * `Surface.LiveView` - A wrapper component around `Phoenix.LiveView`.
    * `Surface.MacroComponent` - A low-level component which is responsible for translating its own content at compile time.

  ### Example

      # A functional stateless component

      defmodule Button do
        use Surface.Component

        property click, :event
        property kind, :string, default: "is-info"

        def render(assigns) do
          ~H"\""
          <button class="button {{ @kind }}" phx-click={{ @click }}>
            <slot/>
          </button>
          "\""
        end
      end

  You can visit the documentation of each type of component for further explanation and examples.
  """

  @doc """
  Translates Surface code into Phoenix templates.
  """
  defmacro sigil_H({:<<>>, _, [string]}, _) do
    line_offset = __CALLER__.line + 1

    string
    |> Surface.Translator.run(line_offset, __CALLER__, __CALLER__.file)
    |> EEx.compile_string(
      engine: Phoenix.LiveView.Engine,
      line: line_offset,
      file: __CALLER__.file
    )
  end

  @doc false
  def component(module, assigns) do
    module.render(assigns)
  end

  def component(module, assigns, []) do
    module.render(assigns)
  end

  @doc false
  def put_default_props(props, mod) do
    Enum.reduce(mod.__props__(), props, fn %{name: name, opts: opts}, acc ->
      default = Keyword.get(opts, :default)
      Map.put_new(acc, name, default)
    end)
  end

  @doc false
  def begin_context(props, current_context, mod) do
    assigns = put_gets_into_assigns(props, current_context, mod.__context_gets__())

    initialized_context_assigns =
      with true <- function_exported?(mod, :init_context, 1),
           {:ok, values} <- mod.init_context(assigns) do
        Map.new(values)
      else
        false ->
          []

        {:error, message} ->
          runtime_error(message)

        result ->
          runtime_error(
            "unexpected return value from init_context/1. " <>
              "Expected {:ok, keyword()} | {:error, String.t()}, got: #{inspect(result)}"
          )
      end

    {assigns, new_context} =
      put_sets_into_assigns_and_context(
        assigns,
        current_context,
        initialized_context_assigns,
        mod.__context_sets__()
      )

    assigns = Map.put(assigns, :__surface_context__, new_context)

    {assigns, new_context}
  end

  @doc false
  def end_context(context, mod) do
    Enum.reduce(mod.__context_sets__(), context, fn %{name: name, opts: opts}, acc ->
      to = Keyword.fetch!(opts, :to)
      context_entry = acc |> Map.get(to, %{}) |> Map.delete(name)

      if context_entry == %{} do
        Map.delete(acc, to)
      else
        Map.put(acc, to, context_entry)
      end
    end)
  end

  @doc false
  def attr_value(attr, value) do
    if String.Chars.impl_for(value) do
      value
    else
      runtime_error(
        "invalid value for attribute \"#{attr}\". Expected a type that implements " <>
          "the String.Chars protocol (e.g. string, boolean, integer, atom, ...), " <>
          "got: #{inspect(value)}"
      )
    end
  end

  @doc false
  def style(value, show) when is_binary(value) do
    if show do
      quot(value)
    else
      semicolon = if String.ends_with?(value, ";") || value == "", do: "", else: ";"
      quot([value, semicolon, "display: none;"])
    end
  end

  def style(value, _show) do
    runtime_error(
      "invalid value for attribute \"style\". Expected a string " <>
        "got: #{inspect(value)}"
    )
  end

  @doc false
  def css_class(list) when is_list(list) do
    Enum.reduce(list, [], fn item, classes ->
      case item do
        {class, true} ->
          [to_string(class) | classes]

        class when is_binary(class) or is_atom(class) ->
          [to_string(class) | classes]

        _ ->
          classes
      end
    end)
    |> Enum.reverse()
    |> Enum.join(" ")
  end

  def css_class(value) when is_binary(value) do
    value
  end

  @doc false
  def boolean_attr(name, value) do
    if value do
      name
    else
      ""
    end
  end

  @doc false
  def event_value(key, [event], caller_cid) do
    event_value(key, event, caller_cid)
  end

  def event_value(key, [name | opts], caller_cid) do
    event = Map.new(opts) |> Map.put(:name, name)
    event_value(key, event, caller_cid)
  end

  def event_value(_key, nil, _caller_cid) do
    nil
  end

  def event_value(_key, name, nil) when is_binary(name) do
    %{name: name, target: :live_view}
  end

  def event_value(_key, name, caller_cid) when is_binary(name) do
    %{name: name, target: to_string(caller_cid)}
  end

  def event_value(_key, %{name: _, target: _} = event, _caller_cid) do
    event
  end

  def event_value(key, event, _caller_cid) do
    runtime_error(
      "invalid value for event \"#{key}\". Expected an :event or :string, got: #{inspect(event)}"
    )
  end

  @doc false
  def on_phx_event(phx_event, [event], caller_cid) do
    on_phx_event(phx_event, event, caller_cid)
  end

  def on_phx_event(phx_event, [event | opts], caller_cid) do
    value = Map.new(opts) |> Map.put(:name, event)
    on_phx_event(phx_event, value, caller_cid)
  end

  def on_phx_event(phx_event, %{name: name, target: :live_view}, _caller_cid) do
    [phx_event, "=", quot(name)]
  end

  def on_phx_event(phx_event, %{name: name, target: target}, _caller_cid) do
    [phx_event, "=", quot(name), " phx-target=", quot(target)]
  end

  # Stateless component or a liveview (no caller_id)
  def on_phx_event(phx_event, event, nil) when is_binary(event) do
    [phx_event, "=", quot(event)]
  end

  def on_phx_event(phx_event, event, caller_cid) when is_binary(event) do
    [phx_event, "=", quot(event), " phx-target=", to_string(caller_cid)]
  end

  def on_phx_event(_phx_event, nil, _caller_cid) do
    []
  end

  def on_phx_event(phx_event, event, _caller_cid) do
    runtime_error(
      "invalid value for \":on-#{phx_event}\". " <>
        "Expected a :string or :event, got: #{inspect(event)}"
    )
  end

  @doc false
  def phx_event(_phx_event, value) when is_binary(value) do
    value
  end

  def phx_event(phx_event, value) do
    runtime_error(
      "invalid value for \"#{phx_event}\". LiveView bindings only accept values " <>
        "of type :string. If you want to pass an :event, please use directive " <>
        ":on-#{phx_event} instead. Expected a :string, got: #{inspect(value)}"
    )
  end

  defp quot(value) do
    [{:safe, "\""}, value, {:safe, "\""}]
  end

  defp runtime_error(message) do
    stacktrace =
      self()
      |> Process.info(:current_stacktrace)
      |> elem(1)
      |> Enum.drop(2)

    reraise(message, stacktrace)
  end

  defp put_gets_into_assigns(assigns, context, gets) do
    Enum.reduce(gets, assigns, fn %{name: name, opts: opts}, acc ->
      key = Keyword.get(opts, :as, name)
      from = Keyword.fetch!(opts, :from)
      # TODO: raise an error if it's required and it hasn't been set
      value = context[from][name]
      Map.put_new(acc, key, value)
    end)
  end

  defp put_sets_into_assigns_and_context(assigns, context, values, sets) do
    Enum.reduce(sets, {assigns, context}, fn %{name: name, opts: opts}, {assigns, context} ->
      to = Keyword.fetch!(opts, :to)
      scope = Keyword.get(opts, :scope)

      case Map.fetch(values, name) do
        {:ok, value} ->
          new_context_entry =
            context
            |> Map.get(to, %{})
            |> Map.put(name, value)

          new_context = Map.put(context, to, new_context_entry)

          new_assigns =
            if scope == :only_children, do: assigns, else: Map.put(assigns, name, value)

          {new_assigns, new_context}

        :error ->
          {assigns, context}
      end
    end)
  end
end
