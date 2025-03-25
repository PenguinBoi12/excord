defmodule Excord.Type.Message do
  @type snowflake :: String.t()
  @type timestamp :: String.t()

  @type t :: %__MODULE__{
    id: snowflake,
    channel_id: snowflake,
    author: User.t(),
    content: String.t(),
    tts: Boolean.t(),
    mention_everyone: Boolean.t(),
    mentions: [User.t()],
    mention_roles: [snowflake],
    attachments: [Attachment.t()],
    embeds: [Embed.t()],
    reactions: [Reaction.t()],
    nonce: snowflake,
    pinned: Boolean.t(),
    webhook_id: snowflake | nil,
    timestamp: timestamp,
    edited_timestamp: timestamp | nil,
  }

  defstruct [
    :id,
    :channel_id,
    :author,
    :content,
    :timestamp,
    :edited_timestamp,
    :tts,
    :mention_everyone,
    :mentions,
    :mention_roles,
    :attachments,
    :embeds,
    :reactions,
    :nonce,
    :pinned,
    :webhook_id
  ]

  def from_map(map),
    do: {:ok, struct(__MODULE__, map)}
end