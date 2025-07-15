defmodule Excord.Type.Command do
  @moduledoc """
  Represents metadata for a command.
  """

  @type t :: %__MODULE__{
    name: atom(),
    description: String.t(),
    module: module(),
    function: atom(),
    args: [atom()],
    options: [map()]
  }

  defstruct [
    :name,
    :description,
    :module,
    :function,
    args: [],
    options: []
  ]
end
