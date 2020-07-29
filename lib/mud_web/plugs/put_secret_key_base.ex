defmodule MudWeb.Plug.PutSecretKeyBase do

  def init(_params) do
  end

  def call(conn, _params) do
    put_in conn.secret_key_base, "DnsuaShmmdnKJSi3298SndUDhwenkD()*2390Jknd(*D972NdnUD(*98223NdM<ND9*&D"
  end
end
