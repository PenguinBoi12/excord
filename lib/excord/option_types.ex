defmodule Excord.OptionTypes do
  @moduledoc """
  Provides macros for defining Discord application command option types.

  ## Supported Option Types

  The following Discord option types are supported, represented by their numeric values:

  - `1`  — `SUB_COMMAND`
  - `2`  — `SUB_COMMAND_GROUP`
  - `3`  — `STRING`
  - `4`  — `INTEGER`
  - `5`  — `BOOLEAN`
  - `6`  — `USER`
  - `7`  — `CHANNEL` (Includes all channel types + categories)
  - `8`  — `ROLE`
  - `9`  — `MENTIONABLE` (Includes users and roles)
  - `10` — `NUMBER` (Any double between -2^53 and 2^53)
  - `11` — `ATTACHMENT`

  ## Example

  ```elixir
  string :query, description: "Search query", required: true
  integer :limit, description: "Number of results", required: false
  boolean :public, description: "Visible to others", required: false
  ```

  ## Reference

  For more details on option types, see the official Discord docs:
  https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-type
  """

  defmacro string(name, opts \\ []) do
    quote do
      Module.put_attribute(
        __MODULE__,
        :current_command_options,
        %{
          type: 3,
          name: unquote(name),
          choices: []
        } |> Map.merge(Enum.into(unquote(opts), %{}))
      )
    end
  end

  defmacro integer(name, opts \\ []) do
    quote do
      Module.put_attribute(
        __MODULE__,
        :current_command_options,
        %{
          type: 4,
          name: unquote(name)
        } |> Map.merge(Enum.into(unquote(opts), %{}))
      )
    end
  end

  defmacro boolean(name, opts \\ []) do
    quote do
      Module.put_attribute(
        __MODULE__,
        :current_command_options,
        %{
          type: 5,
          name: unquote(name)
        } |> Map.merge(Enum.into(unquote(opts), %{}))
      )
    end
  end
end
