defmodule MudWeb.PlayerResetPasswordControllerTest do
  use MudWeb.ConnCase, async: true

  alias Mud.Account
  alias Mud.Repo
  import Mud.AccountFixtures

  setup do
    %{player: player_fixture()}
  end

  describe "GET /players/reset_password" do
    test "renders the reset password page", %{conn: conn} do
      conn = get(conn, Routes.player_reset_password_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Forgot your password?</h1>"
    end
  end

  describe "POST /players/reset_password" do
    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, player: player} do
      conn =
        post(conn, Routes.player_reset_password_path(conn, :create), %{
          "player" => %{"email" => player.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Account.PlayerToken, player_id: player.id).context == "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.player_reset_password_path(conn, :create), %{
          "player" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Account.PlayerToken) == []
    end
  end

  describe "GET /players/reset_password/:token" do
    setup %{player: player} do
      token =
        extract_player_token(fn url ->
          Account.deliver_player_reset_password_instructions(player, url)
        end)

      %{token: token}
    end

    test "renders reset password", %{conn: conn, token: token} do
      conn = get(conn, Routes.player_reset_password_path(conn, :edit, token))
      assert html_response(conn, 200) =~ "<h1>Reset password</h1>"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, Routes.player_reset_password_path(conn, :edit, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end

  describe "PUT /players/reset_password/:token" do
    setup %{player: player} do
      token =
        extract_player_token(fn url ->
          Account.deliver_player_reset_password_instructions(player, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, player: player, token: token} do
      conn =
        put(conn, Routes.player_reset_password_path(conn, :update, token), %{
          "player" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(conn) == Routes.player_session_path(conn, :new)
      refute get_session(conn, :player_token)
      assert get_flash(conn, :info) =~ "Password reset successfully"
      assert Account.get_player_by_email_and_password(player.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, Routes.player_reset_password_path(conn, :update, token), %{
          "player" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Reset password</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
    end

    test "does not reset password with invalid token", %{conn: conn} do
      conn = put(conn, Routes.player_reset_password_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end
end
