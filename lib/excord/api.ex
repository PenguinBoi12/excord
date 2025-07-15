defmodule Excord.Api do
  use GenServer

  require Req
  require Jason

  @discord_version 10
  @discord_url "https://discord.com/api/v#{@discord_version}"

  def start_link([module: module, config: config]) do
    token = Keyword.get(config, :token) || raise "'token' is missing"

    state = %{
      bot: module,
      token: token
    }

    name = Module.concat(module, Excord.Api)
    GenServer.start_link(__MODULE__, state, name: name)
  end

  def request(bot, method, url, params_or_body \\ [])

  def request(bot, :get, url, params) do
    req = Req.new(
      method: :get,
      base_url: @discord_url,
      url: url,
      params: params
    )

    GenServer.call(bot, {:request, req})
  end

  def request(bot, :post, url, body) do
    req = Req.new(
      method: :post,
      base_url: @discord_url,
      url: url,
      body: Jason.encode!(body)
    )

    GenServer.call(bot, {:request, req})
  end

  def request(bot, :put, url, body) do
    req = Req.new(
      method: :put,
      base_url: @discord_url,
      url: url,
      body: Jason.encode!(body)
    )

    GenServer.call(bot, {:request, req})
  end

  def request(bot, :delete, url, body) do
    req = Req.new(
      method: :delete,
      base_url: @discord_url,
      url: url,
      body: Jason.encode!(body)
    )

    GenServer.call(bot, {:request, req})
  end

  def init(state), do: {:ok, state}

  def handle_call({:request, req}, _from, state) do
    req = Req.merge(req, 
      headers: %{
        authorization: "Bot #{state.token}",
        user_agent: "Excord 1.0.0-rc.1 (https://github.com/PenguinBoi12/excord)",
        content_type: "application/json"
      })

    {_, resp} = Req.run!(req, decode_json: [keys: :atoms])
    {:reply, resp, state}
  end
end
