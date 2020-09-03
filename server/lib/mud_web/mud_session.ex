defmodule MudWeb.MudSession do
  @moduledoc """
  Methods for working with the custom session handling logic.
  """

  @one_day_seconds 60 * 60 * 24 # 1 day
  # @one_hour_seconds 60 * 60 # 1 hour

  @namespace "mud session"

  @doc """
  Create a new token.

  Accepts an optional player_id, which if present indicates the session is authenticated.
  """
  @spec new(any) :: String.t()
  def new(player_id \\ "") do
    Phoenix.Token.sign(MudWeb.Endpoint, @namespace, player_id)
  end

  @doc """
  Verify a token is valid
  """
  @spec verify(binary) :: {:error, :expired | :invalid | :missing} | {:ok, String.t()}
  def verify(token) do
    Phoenix.Token.verify(MudWeb.Endpoint, @namespace, token, @one_day_seconds)
  end


  @doc """
  Renew a token by extracting the data and then signing a new token if it requires it. Pass true to force renewal.

  Note: This should not be called on every request as it returns a new token and multiple parallel requests, each one
  generating a new token, could cause undefined behaviour.
  """
  @spec renew(String.t()) :: String.t()
  def renew(token) do
    {:ok, data} = Phoenix.Token.verify(MudWeb.Endpoint, @namespace, token)
    Phoenix.Token.sign(MudWeb.Endpoint, @namespace, data)
  end
end
