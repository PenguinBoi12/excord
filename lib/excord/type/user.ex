defmodule Excord.Type.User do
  @type snowflake :: String.t()

  @type t :: %__MODULE__{
    id: snowflake,
    username: String.t(),
    discriminator: String.t(),
    global_name: String.t() | nil,
    avatar: String.t() | nil,
    bot: boolean | nil,
    system: boolean | nil,
    mfa_enabled: boolean | nil,
    banner: String.t() | nil,
    accent_color: integer | nil,
    locale: String.t() | nil,
    verified: boolean | nil,
    email: String.t() | nil,
    flags: integer | nil,
    premium_type: integer | nil,
    public_flags: integer | nil,
    avatar_decoration: String.t() | nil
  }

  defstruct [
    :id,
    :username,
    :discriminator,
    :global_name,
    :avatar,
    :bot,
    :system,
    :mfa_enabled,
    :banner,
    :accent_color,
    :locale,
    :verified,
    :email,
    :flags,
    :premium_type,
    :public_flags,
    :avatar_decoration
  ]

  @spec from_map(map()) :: {:ok, t()}
  def from_map(map),
    do: {:ok, struct(__MODULE__, map)}
end
