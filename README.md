# Excord

> Quick to launch, easy to scale, and effortless!

<a href="https://discord.gg/code-society-823178343943897088">
  <img src="https://discordapp.com/api/guilds/823178343943897088/widget.png?style=shield" alt="Join on Discord">
</a>
<a href="https://opensource.org/licenses/gpl-3.0">
  <img src="https://img.shields.io/badge/License-GPL%203.0-blue.svg" alt="License">
</a>
<a href="https://hexdocs.pm/elixir">
  <img src="https://img.shields.io/badge/Elixir-1.18.1-4e2a8e" alt="Elixir">
</a>

**Excord** is an Discord wrapper written in Elixir, designed to build scalable and reliable Discord bots quickly and effortlessly.

## Installation

Excord is not yet available on Hex, so you need to install it directly from GitHub:

```elixir
def deps do
  [
    {:excord, github: "PenguinBoi12/excord"}
  ]
end
```

Note: Excord requires Elixir 1.18 or higher.

## Getting Started

### 1. Define Your Bot

Create a bot module using `Excord.Bot`:

```elixir
defmodule MyBot do
  use Excord.Bot, otp_app: :my_bot

  # /ping
  command ping(ctx, _args) do
    Message.send(ctx, "Pong!")
  end

  on ready(_) do
    IO.puts("Your bot is online and ready to use!")
  end
end
```

### 2. Configure Your Bot

Add your bot's configuration in `config/config.exs`

```elixir
config :excord_example, MyBot,
  token: System.get_env("TOKEN") || raise "enviroment variable TOKEN is missing"
```

### 3. Add Your Bot to the Supervisor

Finally, include your bot in the application's supervision tree:

```elixir
defmodule MyBot.Application do
  use Application

  def start(_type, _args) do
    children = [
      MyBot
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```

## Need Help?

If you need help don't hestiate to contact me (Malassi) on [Discord](https://discord.gg/FzgwHD7Am3).

## Contribution

If you'd like to help me or improve the project, I welcome any contributions to Excord!
