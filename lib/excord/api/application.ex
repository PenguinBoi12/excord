defmodule Excord.Api.Application do
  @moduledoc """
  Discord API's application.

  See: https://discord.com/developers/docs/resources/application
  """
  require Logger

  alias Excord.Api
  alias Excord.Type.User

  @type snowflake :: String.t() | Integer.t()
  @type result :: {:ok, User.t() | map()} | {:error, Integer.t() | map()}

  @route "/applications/"

  defp build_route(app_id, [guild: guild]),
    do: "#{@route}#{app_id}/guilds/#{guild}"

  defp build_route(app_id, _),
    do: "#{@route}#{app_id}"

  @spec me(pid()) :: result()
  def me(bot) do
    case Api.request(bot, :get, @route <> "@me") do
      %{status: 200, body: body} -> User.from_map(body)
      err -> {:error, err}
    end
  end

  @spec sync(pid(), list(), keyword()) :: result()
  def sync(bot, commands, opts \\ []) do
    Logger.warning("Syncing application commands for #{inspect(bot)}")

    with {:ok, %User{id: app_id}} <- me(bot),
         route <- build_route(app_id, opts),
         payloads <- build_commands(commands),
         {:ok, resp} <- register_commands(bot, route, payloads) do
      {:ok, resp}
    else
      {:error, reason} ->
        Logger.error("Failed to register commands: #{inspect(reason)}")
        {:error, reason}

      err ->
        Logger.error("Unexpected error: #{inspect(err)}")
        {:error, err}
    end
  end

  defp build_commands(commands) do
    Enum.map commands, fn {_mod, name, options, description} ->
      %{
        type: 1,
        name: Atom.to_string(name),
        description: description,
        options: options
      }
    end
  end

  defp register_commands(bot, route, payloads) do
    case Api.request(bot, :put, "#{route}/commands", payloads) do
      %{status: 200} = response -> {:ok, response}
      error_response -> {:error, error_response}
    end
  end
end