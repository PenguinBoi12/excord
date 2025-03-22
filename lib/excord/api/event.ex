defmodule Excord.Api.Event do
  require Logger

  @registry_name :excord_event_registry

  def dispatch({event, data}) do
    Registry.dispatch @registry_name, event, fn entries ->
      for {_pid, module} <- entries do
        try do
          apply(module, event, [data])
        rescue e ->
          Logger.error("Error dispatching #{event} to #{inspect(module)}: #{inspect(e)}")
        end
      end
    end
  end

  def register(event, module),
    do: Registry.register(@registry_name, event, module)

  def handle_event("READY", data), 
    do: dispatch({:on_ready, data})

  def handle_event("RESUMED", data), 
    do: dispatch({:on_resumed, data})

  def handle_event("TYPING_START", data), 
    do: dispatch({:on_typing, data})

  # GUILD
  def handle_event("GUILD_CREATE", data),
    do: dispatch({:on_guild_create, data})

  def handle_event("GUILD_UPDATE", data),
    do: dispatch({:on_guild_update, data})

  def handle_event("GUILD_DELETE", data),
    do: dispatch({:on_guild_delete, data})

  # MESSAGE
  def handle_event("MESSAGE_CREATE", data),
    do: dispatch({:on_message, data})

  def handle_event("MESSAGE_UPDATE", data),
    do: dispatch({:on_message_edit, data})

  def handle_event("MESSAGE_DELETE", data),
    do: dispatch({:on_message_delete, data})

  def handle_event("MESSAGE_DELETE_BULK", data),
    do: dispatch({:on_bulk_message_delete, data})

  def handle_event("MESSAGE_REACTION_ADD", data),
    do: dispatch({:on_reaction_add, data})

  def handle_event("MESSAGE_REACTION_REMOVE", data),
    do: dispatch({:on_reaction_remove, data})

  # USERS

  # THREAD

  # VOICE

  # INTEGRATION

  # INVITE

  # PRESENCE

  def handle_event(event, _data, _state),
    do: Logger.warning("Event #{event} not found")
end