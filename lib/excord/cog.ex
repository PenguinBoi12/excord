defmodule Excord.Cog do
  defmacro __using__([name: name]) do
    quote do
      import unquote(__MODULE__)
      require Logger

      @events []
      @commands []
      @current_cog unquote(name)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __commands__ do
        @commands
      end

      def __events__ do
        @events
      end
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

  defmacro on(func, body) do
    {name, ctx, args} = func
    event = String.to_atom("on_#{name}")

    quote do
      unquote({:def, ctx, [{event, ctx, args}, body]})

      unless Enum.member?(@events, unquote(event)) do
        @events [unquote(event) | @events]

        def __register_event__(unquote(event)) do
          Excord.Api.Event.register(unquote(event), __MODULE__)
        end
      end
    end
  end
end