defmodule Excord do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :duplicate, name: :event_registry},
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
