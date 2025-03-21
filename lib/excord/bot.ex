defmodule Excord.Bot do
  require Logger

  @callback handle_command(identifier :: atom(), ctx :: map(), args :: list()) :: any()
  @callback handle_command(group :: atom(), identifier :: atom(), ctx :: map(), args :: list()) :: any()
  @callback handle_event(event :: atom(), args :: any()) :: any()

  @optional_callbacks handle_command: 3, handle_command: 4, handle_event: 2

  defmacro __using__(opts) do
    quote do
      @behaviour Excord.Bot

      import unquote(__MODULE__)
      require Logger

      @otp_app unquote(opts)[:otp_app] || raise("bot expects :otp_app to be given")

      unquote(server())
      unquote(handlers())
    end
  end

  defp server() do
    quote do
      use Supervisor

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :supervisor
        }
      end

      def start_link(opts \\ []) do
        Supervisor.start_link(__MODULE__, [unquote(__MODULE__)], name: __MODULE__)
      end

      def init(_opts) do
        children = [
          {Excord.Api.Gateway, [bot_module: __MODULE__, otp_app: @otp_app]}
        ]

        Supervisor.init(children, strategy: :one_for_one)
      end

      defoverridable start_link: 0
    end
  end

  defp handlers() do
    quote do
      def handle_command(_, _, _) do
        {:error, :command_not_found}
      end

      def handle_command(_, _, _, _) do
        {:error, :command_not_found}
      end

      def handle_event(_, _) do
        nil
      end

      defoverridable handle_command: 3, handle_command: 4, handle_event: 2
    end
  end

  defmacro command(func, body) do
    {name, ctx, args} = func

    quote do
      Logger.debug("Registering command #{unquote(name)}")
      unquote({:def, ctx, [{name, ctx, args}, body]})

      def handle_command(unquote(name), ctx, args) do
        apply(__MODULE__, unquote(name), [ctx, args])
      end
    end
  end

  defmacro on(func, body) do
    {name, ctx, args} = func

    quote do
      Logger.debug("Registering event on_#{unquote(name)}")
      unquote({:def, ctx, [{:"on_#{name}", ctx, args}, body]})
    end
  end

  defmacro cog(module_ast) do
    module = Macro.expand(module_ast, __CALLER__)
    commands = module.__commands__()

    quote do
      unquote_splicing(Enum.map(commands, fn
        {group, {module, identifier}} ->
          quote do
            def handle_command(unquote(group), unquote(identifier), ctx, args) do
              apply(unquote(module), unquote(identifier), [ctx, args])
            end
          end
        {module, identifier} ->
          quote do
            def handle_command(unquote(identifier), ctx, args) do
              apply(unquote(module), unquote(identifier), [ctx, args])
            end
          end
      end))
    end
  end
end