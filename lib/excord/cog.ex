defmodule Excord.Cog do
  defmacro __using__([name: name]) do
    quote do
      import unquote(__MODULE__)
      require Logger

      @commands []
      @current_cog unquote(name)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __commands__, do: @commands

      def handle_event(event, data), do: nil
    end
  end

  defmacro command(func, body) do
    {name, ctx, args} = func

    quote do
      Logger.debug("Registering command #{unquote(name)}")

      command = {__MODULE__, unquote(name)}
      unquote({:def, ctx, [{name, ctx, args}, body]})

      unless Enum.member?(@commands, command) do
        @commands [command | @commands]
      end
    end
  end

  defmacro subcommand(func, body) do
    {name, ctx, args} = func

    quote do
      Logger.debug("Registering subcommand #{@current_cog}:#{unquote(name)}")

      command = {__MODULE__, unquote(name)}
      unquote({:def, ctx, [{name, ctx, args}, body]})

      unless Enum.member?(@commands, command) do
        @commands [command | @commands]
      end
    end
  end

  defmacro on({name, _ctx, args}, do: block) do
    event = String.to_atom("on_#{name}")

    quote do
      def handle_event(unquote(event), unquote_splicing(args)) do
        unquote(block)
      end
    end
  end
end