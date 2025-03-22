defmodule Excord.Api.Gateway do
  use WebSockex

  require Logger
  require Jason

  @discord_version 10
  @gateway_url "wss://gateway.discord.gg/?v=#{@discord_version}&encoding=json"

  def start_link([module: module, config: config]) do
    token = Keyword.get(config, :token) || raise "'token' is missing"
    intents = Keyword.get(config, :intents, 513)
    activities = Keyword.get(config, :activities, [])

    state = %{
      bot: module,
      token: token,
      intents: intents,
      activities: activities,
      seq: nil,
      heartbeat_interval: nil,
      last_heartbeat_ack: true
    }

    name = Module.concat(module, Excord.Api.Gateway)
    WebSockex.start_link(@gateway_url, __MODULE__, state, name: name)
  end

  def handle_frame({:text, msg}, state),
    do: Jason.decode!(msg, keys: :atoms) |> handle_payload(state)

  defp handle_payload(%{op: 10, d: %{heartbeat_interval: interval}}, state) do
    Logger.info("Connected to Discord Gateway")

    identify(state)
    schedule_heartbeat(interval)

    {:ok, %{state | heartbeat_interval: interval}}
  end

  defp handle_payload(%{op: 0, t: event, s: seq, d: data}, state) do
    Logger.debug("Received Gateway Event: #{event}")

    {event, data} = Excord.Api.Event.handle_event(event, data)
    Excord.Api.Event.dispatch(state.bot, event, data)

    {:ok, %{state | seq: seq}}
  end

  defp handle_payload(%{op: 11}, state),
    do: {:ok, %{state | last_heartbeat_ack: true}}

  defp handle_payload(%{op: op}, state) do
    Logger.debug("Received Gateway Op #{op}")
    {:ok, state}
  end

  def handle_info(:heartbeat, %{last_heartbeat_ack: true} = state) do
    Logger.debug("Sending heartbeat")

    send_heartbeat(state.seq)
    schedule_heartbeat(state.heartbeat_interval)

    {:ok, %{state | last_heartbeat_ack: false}}
  end

  def handle_info(:heartbeat, state) do
    Logger.warning("No heartbeat ACK received, reconnecting...")
    {:close, {1000, "No heartbeat ACK"}, state}
  end

  def handle_cast({:send, frame}, state),
    do: {:reply, {:text, frame}, state}

  def handle_disconnect(_disconnect_map, state) do
    Logger.warning("Gateway disconnected, reconnecting...")
    {:reconnect, state}
  end

  defp send_payload(data) do
    payload = Jason.encode!(data)
    WebSockex.cast(self(), {:send, payload})
  end

  defp send_heartbeat(seq),
    do: send_payload(%{op: 1, d: seq})

  defp schedule_heartbeat(interval),
    do: Process.send_after(self(), :heartbeat, interval)

  defp identify(state) do
    {_, os_name} = :os.type

    send_payload(%{
      op: 2,
      d: %{
        token: state.token,
        intents: state.intents,
        properties: %{
          os: os_name,
          browser: "excord",
          device: "excord"
        },
        presence: %{
          activities: state.activities,
          status: "online",
          afk: false
        },
      }
    })
  end
end