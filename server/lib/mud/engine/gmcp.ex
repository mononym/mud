defmodule Mud.Engine.GMCP do
  require Logger

  defmodule Message do
    use TypedStruct

    typedstruct do
      field(:package, String.t())
      field(:message, String.t())
      field(:data, map())
    end
  end

  # end of subnegotiation
  @se 0xF0
  # start of subnegotiation
  @sb 0xFA
  @will 0xFB
  @wont 0xFC
  @execute 0xFD
  @dont 0xFE
  # Interpret As Command
  @iac 0xFF
  # GMCP sequence (decimal 201)
  @gmcp 0xC9

  def start_handshake_message() do
    <<@iac, @will, @gmcp>>
  end

  def binary_starts_with_complete_gmcp_message?(<<@iac, @sb, @gmcp, rest::binary>>) do
    case :binary.match(rest, [<<@iac, @se>>]) do
      :nomatch ->
        false

      _ ->
        true
    end
  end

  def binary_starts_with_complete_gmcp_message(_) do
    false
  end

  def client_accepts_gmcp(client_response) do
    case :binary.match(client_response, [<<@iac, @execute, @gmcp>>]) do
      {0, 3} ->
        {_response, buffer} = :erlang.split_binary(client_response, 3)

        {:ok, buffer}

      :nomatch ->
        {:error, client_response}
    end
  end

  def parse_gmcp_message(<<@iac, @sb, @gmcp, message::binary>>) do
    [message, bin] = :binary.split(message, <<@iac, @se>>)
    Logger.debug("parsing gmcp message: #{inspect(message)}")

    string = List.to_string([message])

    case String.split(string, " ", parts: 2) do
      [prefix, raw_json] ->
        [package, message] = String.split(prefix, ".", parts: 2)

        msg = %Message{
          package: package,
          message: message,
          data: Jason.decode!(raw_json)
        }

        Logger.debug("parsed gmcp message: #{inspect(msg)}")

        {msg, bin}

      [prefix] ->
        [package, message] = String.split(prefix, ".", parts: 2)

        msg = %Message{
          package: package,
          message: message
        }

        Logger.debug("parsed gmcp message: #{inspect(msg)}")
        {msg, bin}
    end
  end

  def parse_gmcp_message(bin) do
    {nil, bin}
  end

  def create_gmcp_string(input) do
    "#{@iac}#{@sb}#{@gmcp}#{input}#{@iac}#{@se}"
  end

  # def parse_gmcp_messages(bytes) do
  #   case :binary.matches(bytes, <<@iac, @se>>) do
  #     [] ->
  #       {:error, :no_gmcp_message}

  #     matches ->
  #       Enum.map(matches, fn match ->
  #         :binary.part()
  #       end)
  #   end

  #   :binary.split(bytes, [<<0, 0, 0>>, <<2>>], [])
  #   <<message::binary, @iac, @se(rest :: binary)>> = bytes
  # end
end
