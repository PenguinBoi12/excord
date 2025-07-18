defmodule Excord.OptionTypes do
  defmacro string(name, opts \\ []) do
    quote do
      Module.put_attribute(
        __MODULE__,
        :current_command_options,
        %{type: :string, name: unquote(name)} |> Map.merge(Enum.into(unquote(opts), %{}))
      )
    end
  end

  defmacro integer(name, opts \\ []) do
    quote do
      Module.put_attribute(
        __MODULE__,
        :current_command_options,
        %{type: :integer, name: unquote(name)} |> Map.merge(Enum.into(unquote(opts), %{}))
      )
    end
  end
end
