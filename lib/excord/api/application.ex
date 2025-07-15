defmodule Excord.Api.Application do
  @moduledoc """
  Discord API's application.

  See: https://discord.com/developers/docs/resources/application
  """
  require Logger

  alias Excord.Api
  alias Excord.Type.User

  @type snowflake :: String.t() | Integer.t()
  @type result :: {:ok, User.t()} | {:error, Integer.t()}

  @route "/applications/"

  @spec me(pid()) :: result()
  def me(bot) do
    case Api.request(bot, :get, @route <> "@me") do
      %{status: 200, body: body} -> User.from_map(body)
      %{status: status} -> {:error, status}
    end
  end

  def sync(bot, commands) do
    Logger.warning("Syncing slash commands for #{inspect(bot)}")

    # # 1. Get application ID
    {:ok, %User{id: app_id}} = me(bot)

    # 2. Build list of commands
    commands =
      Enum.map(commands, fn {name, _mod} ->
        %{
          name: Atom.to_string(name),
          description: "Slash command for #{name}", # we might be able to fetch this from @doc/@description
          type: 1, # Chat Input
          options: [] # Extend later if needed
        }
      end)

    IO.inspect(commands, label: "registered commands")

    # bot
    # |> Excord.Api.request(:put, @route <> "#{app_id}/commands", commands)

    # 3. Sync commands
    case Excord.Api.request(bot, :put, "#{@route}#{app_id}/commands", commands) do
      {:ok, %Req.Response{status: 200}} ->
        Logger.info("Synced #{length(commands)} commands for #{inspect(bot)}")
        :ok

      # {:ok, %Req.Response{status: code, body: body}} ->
      #   Logger.error("Failed to sync commands (#{code}): #{inspect(body)}")
      #   {:error, body}

      error ->
        Logger.error("Unexpected error during sync: #{inspect(error)}")
        error
    end
  end
end