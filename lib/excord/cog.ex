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
      def __commands__ do
        @commands
      end
    end
  end

  defmacro command(func, body) do
    {name, ctx, args} = func

    quote do
      unquote({:def, ctx, [{name, ctx, args}, body]})

      Logger.info("Register command #{unquote(name)}")
      @commands [{__MODULE__, unquote(name)} | @commands]
    end
  end

  defmacro subcommand(func, body) do
    {name, ctx, args} = func

    quote do
      unquote({:def, ctx, [{name, ctx, args}, body]})

      Logger.info("Register subcommand #{@current_cog}:#{unquote(name)}")
      @commands [{@current_cog, {__MODULE__, unquote(name)}} | @commands]
    end
  end
end