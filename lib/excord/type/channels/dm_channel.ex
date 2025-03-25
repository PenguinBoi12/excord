defmodule Excord.Type.DmChannel do
  defstruct [
    :id,
    :recipients,
    :last_message_id
  ]

  @type snowflake :: String.t()

  @typedoc """

  """
  @type dm_channel :: %__MODULE__{
    id: snowflake,
    # recipients: [User.t()],
    last_message_id: snowflake | nil
  }
end