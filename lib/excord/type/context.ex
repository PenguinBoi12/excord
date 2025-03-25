defmodule Excord.Type.Context do
	alias Excord.Type.Message

	defstruct [
		:channel,
	]

	@type t :: %__MODULE__{
		channel: Message.t()
	}
end