defmodule MudWeb.PlayerAuthController do
  use MudWeb, :controller

  alias Mud.Account

  action_fallback(MudWeb.FallbackController)

  def authenticate_via_email(conn, %{"email" => %{"email" => email}}) do
    case Account.authenticate_via_email(email) do
      {:ok, _} ->
        conn
        |> put_flash(:success, "Please check provided email address for a message from us!")
        |> redirect(to: "/authenticate/token")

      {:error, _} ->
        conn =
          conn
          |> put_flash(
            :error,
            "Something went wrong. Please try again. If error persists please contact support."
          )

        case List.keyfind(conn.req_headers, "referer", 0) do
          {"referer", referer} ->
            redirect(conn, referer)

          nil ->
            redirect(conn, to: "/")
        end
    end
  end

  def show_auth_token_form(conn, _params) do
    conn
    |> put_layout("bare_page.html")
    |> render("auth_token.html",
      changeset: MudWeb.Schema.Token.new() |> MudWeb.Schema.Token.changeset()
    )
  end

  def logout(conn, _params) do
    case List.keyfind(conn.req_headers, "referer", 0) do
      {"referer", referer} ->
        uri = MudWeb.Util.referrer_to_uri(referer)

        conn
        |> clear_session()
        |> redirect(to: uri)

      nil ->
        conn
        |> clear_session()
        |> redirect(to: "/")
    end
  end

  def validate_auth_token(conn, %{"token" => %{"token" => token}}) do
    IO.inspect(token)

    case Account.validate_auth_token(token) do
      {:ok, player} ->
        conn
        |> put_flash(
          :success,
          "Authentication successful!"
        )
        |> put_session("player", player)
        |> redirect(to: "/home")

      _error ->
        conn
        |> put_flash(
          :error,
          "The provided token was invalid. Either it has already been used or it has expired."
        )
        |> redirect(to: "/authenticate/token")
    end
  end
end
