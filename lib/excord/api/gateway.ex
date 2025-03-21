defmodule Excord.Api.Gateway do
  use WebSockex

  require Logger
  require Jason

  @gateway_url "wss://gateway.discord.gg/?v=10&encoding=json"

  def start_link(opts) do
    bot_module = Keyword.get(opts, :bot_module) || raise "Gateway requires :bot_module option"
    otp_app = Keyword.get(opts, :otp_app) || raise "Gateway requires :otp_app option"

    config = Application.get_env(otp_app, bot_module)

    token = Keyword.get(config, :token) || raise "'token' is missing"
    intents = Keyword.get(config, :intents, 513)
    activities = Keyword.get(config, :activities, [])

    state = %{
      bot_module: bot_module,
      otp_app: otp_app,
      token: token,
      intents: intents,
      activities: activities,
      seq: nil,
      heartbeat_interval: nil,
      last_heartbeat_ack: true
    }

    WebSockex.start_link(@gateway_url, __MODULE__, state, name: __MODULE__)
  end

  def handle_frame({:text, msg}, state) do
    payload = Jason.decode!(msg, keys: :atoms)
    handle_payload(payload, state)
  end

  defp handle_payload(%{op: 10, d: %{heartbeat_interval: interval}}, state) do
    Logger.info("Connected to Discord Gateway")

    identify(state)
    schedule_heartbeat(interval)

    {:ok, %{state | heartbeat_interval: interval}}
  end

  defp handle_payload(%{op: 0, t: event, s: seq, d: data}, state) do
    Logger.debug("Received Gateway Event: #{event}")

    {event, data} = Excord.Api.Event.handle_event(event, data)
    apply(state.bot_module, :handle_event, [event, data])

    {:ok, %{state | seq: seq}}
  end

  defp handle_payload(%{op: 11}, state) do
    {:ok, %{state | last_heartbeat_ack: true}}
  end

  defp handle_payload(%{op: op}, state) do
    Logger.debug("Received Gateway Op #{op}")
    {:ok, state}
  end

  def handle_info(:heartbeat, state) do
    if state.last_heartbeat_ack do
      send_heartbeat(state.seq)
      schedule_heartbeat(state.heartbeat_interval)
      {:ok, %{state | last_heartbeat_ack: false}}
    else
      Logger.warning("No heartbeat ACK received, reconnecting...")
      {:close, {1000, "No heartbeat ACK"}, state}
    end
  end

  defp send_heartbeat(seq) do
    payload = Jason.encode!(%{op: 1, d: seq})
    WebSockex.cast(self(), {:send, payload})
  end

  defp schedule_heartbeat(interval) do
    Process.send_after(self(), :heartbeat, interval)
  end

  defp identify(state) do
    {_, os_name} = :os.type

    payload = Jason.encode!(%{
      op: 2,
      d: %{
        token: state.token,
        intents: state.intents,
        properties: %{
          os: os_name,
          browser: "excord",
          device: "excord"
        },
        # TODO: Build this elsewhere?
        presence: %{
          activities: state.activities,
          status: "online",
          since: 91879201,
          afk: false
        },
      }
    })

    WebSockex.cast(self(), {:send, payload})
  end

  def handle_cast({:send, frame}, state) do
    {:reply, {:text, frame}, state}
  end

  def handle_disconnect(_disconnect_map, state) do
    Logger.warning("Gateway disconnected, reconnecting...")
    {:reconnect, state}
  end
end