defmodule Excord.Bot do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      require Logger

      # ...
    end
  end

  defmacro cog(module_ast) do
  	module = Macro.expand(module_ast, __CALLER__)
  	commands = module.__commands__()

    command_matches = for {module, identifier} <- commands do
      quote do
        def handle_command(unquote(identifier), ctx, args) do
          apply(unquote(module), unquote(identifier), [ctx, args])
        end
      end
    end

    subcommand_matches = for {group, {module, identifier}} <- commands do
      quote do
        def handle_command(unquote(group), unquote(identifier), ctx, args) do
          apply(unquote(module), unquote(identifier), [ctx, args])
        end
      end
    end

    {command_matches, subcommand_matches}
  end
end