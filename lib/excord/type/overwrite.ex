defmodule Excord.Type.Overwrite do
  defstruct [
    :id,
    :type,
    :allow,
    :deny
  ]

  @typedoc """
  
  """
  @type snowflake :: String.t()

  @typedoc """
  
  """
  @type overwrite :: %{
    id: snowflake,
    type: String.t(),
    allow: Integer.t(),
    deny: Integer.t()
  }
end