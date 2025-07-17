defmodule Mix.Tasks.Excord.Start do
  use Mix.Task

  @shortdoc "Starts the Discord bot"
  @moduledoc """
  Starts your Excord bot and keeps it running.
  """

  def run(_args) do
    Application.put_env(:excord, :start_bot, true, persistent: true)

    Mix.Task.run("app.start")
    Mix.Tasks.Run.run(["--no-halt"])
  end
end