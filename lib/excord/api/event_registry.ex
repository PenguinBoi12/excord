defmodule Excord.Api.EventRegistry do
  require Logger

  @registry_name :excord_event_registry

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker
    }
  end

  def start_link,
    do: Registry.start_link(keys: :duplicate, name: @registry_name)

  def subscribe(event, module),
    do: Registry.register(@registry_name, event, {module, event})

  def publish(event, data) do
    Registry.dispatch @registry_name, event, fn entries ->
      for {_pid, {module, function}} <- entries do
        try do
          apply(module, function, [data])
        rescue e ->
          Logger.error("Error dispatching event #{event} to #{inspect(module)}.#{function}: #{inspect(e)}")
        end
      end
    end
  end
end