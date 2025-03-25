defmodule Excord.Type.TextChannel do
  alias Excord.Type.Overwrite

  defstruct [
    :id,
    :guild_id,
    :name,
    :type,
    :position,
    :permission_overwrites,
    :rate_limit_per_user,
    :nsfw,
    :topic,
    :last_message_id,
    :parent_id,
    :last_pin_timestamp,
    :flags
  ]

  @typedoc """

  """
  @type snowflake :: String.t()
  
  @typedoc """

  """
  @type timestamp :: String.t()

  @typedoc """

  """
  @type text_channel :: %__MODULE__{
    id: snowflake,
    guild_id: snowflake,
    name: String.t(),
    position: Integer,
    permission_overwrites: [Overwrite.t()],
    rate_limit_per_user: Integer.t(),
    nsfw: Boolean.t(),
    topic: String.t() | nil,
    last_message_id: snowflake | nil,
    parent_id: snowflake | nil,
    last_pin_timestamp: String.t() | nil,
    flags: Integer.t() | nil
  }
end