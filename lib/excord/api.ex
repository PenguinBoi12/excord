defmodule Excord.Api do
  use GenServer

  require Req
  require Jason

  import Excord.Cache

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
    cache_key = build_cache_key(bot, url, params)

    IO.inspect(url, label: "=====>")
    IO.inspect(cache_key)

    cache(cache_key, expire: :timer.minutes(1)) do
      req = Req.new(
        method: :get,
        base_url: @discord_url,
        url: url,
        params: params
      )

      GenServer.call(bot, {:request, req})
    end
  end

  def request(bot, :post, url, body) do
    cache_key = build_cache_key(bot, url, body)

    cache(cache_key, expire: :timer.minutes(1), force: true) do
      req = Req.new(
        method: :post,
        base_url: @discord_url,
        url: url,
        body: Jason.encode!(body)
      )

      GenServer.call(bot, {:request, req})
    end
  end

  def request(bot, :put, url, body) do
    cache_key = build_cache_key(bot, url, body)

    cache(cache_key, expire: :timer.minutes(1), force: true) do
      req = Req.new(
        method: :put,
        base_url: @discord_url,
        url: url,
        body: Jason.encode!(body)
      )

      GenServer.call(bot, {:request, req})
    end
  end

  def request(bot, :delete, url, body) do
    cache_key = build_cache_key(bot, url, body)

    req = Req.new(
      method: :delete,
      base_url: @discord_url,
      url: url,
      body: Jason.encode!(body)
    )

    expire(cache_key)
    GenServer.call(bot, {:request, req})
  end

  def expire_cache(bot, url, params_or_body \\ []),
    do: Cachex.del(:excord_cache, build_cache_key(bot, url, params_or_body))

  def build_cache_key(bot, url, params_or_body),
    do: :erlang.phash2({bot, url, params_or_body})

  def init(state), do: {:ok, state}

  def handle_call({:request, req}, _from, state) do
    req = Req.merge(req,
      headers: %{
        authorization: "Bot #{state.token}",
        user_agent: "Excord 1.0.0-rc.1 (https://github.com/PenguinBoi12/excord)",
        content_type: "application/json"
      }
    )

    {_, resp} = Req.run!(req, decode_json: [keys: :atoms])
    {:reply, resp, state}
  end
end
