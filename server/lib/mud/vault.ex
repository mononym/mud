defmodule Mud.Vault do
  @moduledoc false

  use Cloak.Vault, otp_app: :mud

  @impl GenServer
  def init(config) do
    config =
      Keyword.put(config, :ciphers,
        default:
          {Cloak.Ciphers.AES.GCM,
           tag: "AES.GCM.V1", key: "Cd+sdohrr2AZKsQmhBhoSGEOuPS/rRAvnoEGGlnK0MA="}
      )

    {:ok, config}
  end

  defp decode_env!(var) do
    var
    |> System.get_env("Cd+sdohrr2AZKsQmhBhoSGEOuPS/rRAvnoEGGlnK0MA=")
    |> Base.decode64!()
  end
end
