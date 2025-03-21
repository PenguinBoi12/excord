defmodule Excord.Api.Event do
	require Logger

	# I think using on_... would make things easier later
	# I could define a function in the bot module called on_ready 
	# when on :ready is called.
	def handle_event("READY", data) do
		{:on_ready, data}
	end

	def handle_event("RESUMED", data) do
		{:on_resumed, data}
	end

	def handle_event("TYPING_START", data) do
		{:on_typing, data}
	end

	# GUILD
	def handle_event("GUILD_CREATE", data) do
		{:on_guild_create, data}
	end

	def handle_event("GUILD_UPDATE", data) do
		{:on_guild_update, data}
	end

	def handle_event("GUILD_DELETE", data) do
		{:on_guild_delete, data}
	end

	# MESSAGE
	def handle_event("MESSAGE_CREATE", data) do
		{:on_message, data}
	end

	def handle_event("MESSAGE_UPDATE", data) do
		{:on_message_edit, data}
	end

	def handle_event("MESSAGE_DELETE", data) do
		{:on_message_delete, data}
	end

	def handle_event("MESSAGE_DELETE_BULK", data) do
		{:on_bulk_message_delete, data}
	end

	def handle_event("MESSAGE_REACTION_ADD", data) do
		{:on_reaction_add, data}
	end

	def handle_event("MESSAGE_REACTION_REMOVE", data) do
		{:on_reaction_remove, data}
	end

	# USERS

	# THREAD

	# VOICE

	# INTEGRATION

	# INVITE

	# PRESENCE

	def handle_event(event, _data, _state) do
		Logger.warning("Event #{event} not found")
	end
end