defmodule Excord.Type.Channel do
  alias Excord.Type.{
    TextChannel,
    DmChannel,
  }

  @type t ::
      TextChannel.t()
      | DmChannel.t()
      # | VoiceChannel.t()
      # | GroupDmChannel.t()
      # | CategoryChannel.t()
      # | AnnouncementChannel.t()
      # | AnnouncementThread.t()
      # | PublicThread.t()
      # | PrivateThread.t()
      # | StageVoiceChannel.t()
      # | DirectoryChannel.t()
      # | ForumChannel.t()
      # | MediaChannel.t()

  def from_map(map) do
    struct_by_type = %{
      0 => TextChannel,
      1 => DmChannel,
    }

    case map[:type] do
      nil -> {:error, "Unable to parse channel type: '#{inspect(map)}'"}
      type -> {:ok, struct(struct_by_type[type], map)}
    end
  end
end