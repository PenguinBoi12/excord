defmodule Excord.Api.Message do
  @moduledoc """
  Discord API's messages.

  See: https://discord.com/developers/docs/resources/message
  """
  alias Excord.Type.{
    Context,
    Message,
    TextChannel
  }

  @typedoc false
  @type result :: {:ok, Message.t()} | {:error, Integer.t()}

  # @route "/messages"

  @doc """
  Post a message to a guild text or DM channel.

  See: Excord.Api.Channel.send_message/2

  ## Example

  ```
  Excord.Api.Message.send(channel, content: "My message")
  {:ok, message}
  ```
  """
  @spec send(pid(), TextChannel.t() | Context.t(), keyword()) :: result()
  def send(bot, %Context{channel: channel}, options),
    do: Excord.Api.Channel.send_message(bot, channel.id, options)

  def send(bot, %TextChannel{id: channel_id}, options),
    do: Excord.Api.Channel.send_message(bot, channel_id, options)
end