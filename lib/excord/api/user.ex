defmodule Excord.Api.User do
  @moduledoc """
  Discord API's users.

  See: https://discord.com/developers/docs/resources/user
  """
  alias Excord.Api
  alias Excord.Type.User

  @typedoc false
  @type snowflake :: String.t() | Integer.t()
  @type result :: {:ok, User.t()} | {:error, Integer.t()}

  @route "/users/"

  @doc """
  Get the user by id.

  See: Excord.Api.User.get/2

  ## Example

  ```
  Excord.Api.User.get(bot, id)
  {:ok, user}
  ```
  """
  @spec get(pid(), snowflake()) :: result()
  def get(bot, id) do
    case Api.request(bot, :get, @route <> id) do
      %{status: 200, body: body} -> User.from_map(body)
      %{status: status} -> {:error, status}
    end
  end

  @doc """
  Get the requester user.

  For OAuth2, this requires the identify scope, which will return the object without an email,
  and optionally the email scope, which returns the object with an email if the user has one.

  ## Example

  ```
  Excord.Api.User.me(bot)
  {:ok, user}
  ```
  """
  @spec me(pid()) :: result()
  def me(bot), do: get(bot, "@me")
end