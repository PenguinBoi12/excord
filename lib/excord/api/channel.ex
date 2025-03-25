defmodule Excord.Api.Channel do
  @moduledoc """
  Discord API's channels.

  See: https://discord.com/developers/docs/resources/channel
  """
  alias Excord.Api
  alias Excord.Type.{Message, Channel}

  @type snowflake :: String.t() | Integer.t()
  @type result :: {:ok, Message.t() | Channel.t()} | {:error, Integer.t()}

  @route "/channels/"

  @doc """
  Get a channel by id.

  ## Examples

  ```elixir
  Excord.Api.Channel.get("1349086643562221750")
  {:ok, %Excord.Type.TextChannel{}}
  ```
  """
  @spec get(snowflake()) :: result()
  def get(id) when is_integer(id),
    do: get(to_string(id))

  def get(id) do
    case Api.request(:get, @route <> id) do
      %{status: 200, body: body} -> Channel.from_map(body)
      %{status: status} -> {:error, status}
    end
  end

  @doc """
  Update a channel's settings

  ## Examples

  ```elixir
  Excord.Api.Channel.update("1349086643562221750", [name: "Some name"])
  {:ok, %Excord.Type.TextChannel{}}
  ```

  ## Options

  - `name` (string)
  - `position` (integer)
  - `topic` (string)
  - `nsfw` (boolean)
  - `bitrate` (integer)
  - `user_limit` (integer)
  - `permission_overwrites` ([Overwrite, ...])
  - `parent_id` (string)
  """
  @spec get(snowflake(), keyword()) :: result()
  def get(id, options) when is_integer(id),
    do: update(to_string(id), options)

  def update(id, options) do
    case Api.request(:post, @route <> id, body: options) do
      %{status: 200, body: body} -> Channel.from_map(body)
      %{status: status} -> {:error, status}
    end
  end

  @doc """
  Post a message to a guild text or DM channel.

  ```elixir
  Excord.Api.Channel.send_message("1349086643562221750", [name: "Some name"])
  {:ok, %Excord.Type.TextChannel{}}
  ```

  ## Options:

  - `content` (string)
  - `nonce` (integer or string)
  - `tts` (boolean)
  - `embeds` (list of Embed)
  - `allowed_mentions` (AllowedMention)
  - `message_reference` (MessageReference)
  - `components` (list of Component)
  - `sticker_ids` (list of Snowflake)
  - `files[n]` (file content)
  - `payload_json` (string)
  - `attachments` (Attachment)
  - `flags` (integer)
  - `enforce_nonce` (boolean)
  - `poll` (Pool)

  Note: Must provide at least one of `content`, `embeds`, `sticker_ids`,
        `components`,`files[n]`, or `poll`.
  """
  @spec send_message(snowflake(), keyword()) :: result()
  def send_message(id, options) when is_integer(id),
    do: send_message(to_string(id), options)

  def send_message(id, options) do
    case Api.request(:post, @route <> id <> "/messages", Enum.into(options, %{})) do
      %{status: 200, body: body} -> Message.from_map(body)
      %{status: status} -> {:error, status}
    end
  end
end