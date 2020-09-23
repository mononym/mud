defmodule MudWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel("character:*", MudWeb.CharacterChannel)

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(_, socket, _connect_info) do
    # TODO: security check here
    IO.inspect("connecting user socket")
    # def connect(%{"token" => token}, socket, _connect_info) do
    # case Phoenix.Token.verify(socket, "player salt", token, max_age: 86400) do
    #   {:ok, player_id} ->
    #     socket = assign(socket, :player, Mud.Account.get_player!(player_id))
    {:ok, socket}

    #     {:error, _} ->
    #       :error
    #   end
  end

  # def connect(_params, _socket, _connect_info) do
  #   {:error, "unauthorized"}
  # end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     MudWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  # "user_socket:#{socket.assigns.player_id}"
  def id(_socket), do: nil
end
