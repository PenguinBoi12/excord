defmodule Excord.Cache do
  use GenServer

  @cache_key :excord_cache

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, @cache_key)
    GenServer.start_link(__MODULE__, name, name: name)
  end

  def cache(key, opts \\ [], do: block) do
    is_force = Keyword.get(opts, :force, false)

    if is_force,
      do: expire(key)

    {_, value} = Cachex.fetch @cache_key, key, fn ->
      {:commit, block, opts}
    end

    value
  end

  def get(key),
    do: Cachex.get(@cache_key, key)

  def expire(key),
    do: Cachex.del(@cache_key, key)

  def init(name) do
    case Cachex.start_link(name: name) do
      {:ok, _pid} -> {:ok, name}
      {:error, {:already_started, _pid}} -> {:ok, name}
      error -> {:stop, error}
    end
  end
end
