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

      # Should we do this or let bot implicitly called those?
      alias Excord.Api.{Message, Channel}

      @cogs []
      @commands []

      @otp_app unquote(opts)[:otp_app] || raise("bot expects :otp_app to be given")

      unquote(server())
      unquote(handlers())
      unquote(entrypoints())

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __cogs__, do: @cogs
      def __commands__, do: @commands

      def handle_event(event, data), do: nil
    end
  end

  defp server do
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
        {:ok, pid} = Supervisor.start_link(__MODULE__, [unquote(__MODULE__)], name: __MODULE__)

        Enum.each [__MODULE__ | __cogs__()], fn module ->
          Excord.Api.Event.register(__MODULE__, module)
        end

        {:ok, pid}
      end

      def init(_opts) do
        config = Application.get_env(@otp_app, __MODULE__)
        bot = to_string(__MODULE__) |> String.to_atom()

        children = [
          {Excord.Api, [module: __MODULE__, config: config]},
          {Excord.Api.Gateway, [module: __MODULE__, config: config]}
        ]

        opts = [strategy: :one_for_one, name: __MODULE__.Supervisor]
        Supervisor.init(children, opts)
      end

      defoverridable start_link: 0
    end
  end

  defp handlers do
    quote do
      def handle_command(_, _, _) do
        {:error, :command_not_found}
      end

      def handle_command(_, _, _, _) do
        {:error, :command_not_found}
      end

      def handle_event(event, data) do
        {:error, :event_not_overriden}
      end

      defoverridable handle_command: 3, handle_command: 4, handle_event: 2
    end
  end

  defmacro command(func, body) do
    {name, ctx, args} = func

    quote do
      @commands [{unquote(name), __MODULE__} | @commands]

      Logger.debug("Registering command #{inspect(__MODULE__)}.#{unquote(name)}")
      unquote({:def, ctx, [{name, ctx, args}, body]})

      def handle_command(unquote(name), ctx, args) do
        apply(__MODULE__, unquote(name), [ctx, args])
      end
    end
  end

  defmacro on({name, _meta, args}, do: block) do
    event = String.to_atom("on_#{name}")

    quote do
      Logger.debug("Registering event #{inspect(__MODULE__)}.#{unquote(event)}")

      def handle_event(unquote(event), unquote_splicing(args)) do
        unquote(block)
      end
    end
  end

  defmacro cog(module_ast) do
    module = Macro.expand(module_ast, __CALLER__)
    commands = module.__commands__()

    quote do
      @cogs [unquote(module) | @cogs]

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

  def entrypoints do
    quote do
      @api_process Module.concat(__MODULE__, Excord.Api)

      @doc """
      Entrypoint for discord's message endpoint

      ## Examples

      ```elixir
      message(:send, content: "Hello World")
      ```
      """
      def message(operation, args) when is_list(args),
        do: apply(Excord.Api.Message, operation, [@api_process | args])

      def message(operation, args),
        do: message(operation, [args])

      def message(operation, args, options),
        do: message(operation, [args, options])

      @doc """
      Entrypoint for discord's channel endpoint

      ## Examples

      ```elixir
      channel(:get, 123456789123456789)
      ```
      """
      def channel(operation, args) when is_list(args),
        do: apply(Excord.Api.Channel, operation, [@api_process | args])

      def channel(operation, args),
        do: channel(operation, [args])

      def channel(operation, args, options),
        do: channel(operation, [args, options])

      @doc """
      Entrypoint for discord's application endpoint

      ## Examples

      ```elixir
      application(:sync, commands)
      ```
      """
      def application(operation, args) when is_list(args),
        do: apply(Excord.Api.Application, operation, [@api_process | args])

      def application(operation, args),
        do: application(operation, [args])
    end
  end
end
