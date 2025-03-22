defmodule Excord.Api do
  require Req
  require Jason

  # move this to configs?
  @discord_version 10
  @discord_url "https://discord.com/api/v#{@discord_version}"

  def request(method, token, url, args \\ []) do
    req = Req.new(
      method: method,
      base_url: @discord_url,
      url: url,
      headers: %{
        authorization: "bearer #{token}",
        user_agent: "Excord (https://github.com/PenguinBoi12/excord, 1.0.0-rc.1)"
      }
    )

    do_request(req, args)
  end

  defp do_request(%{method: :get} = req, params) do
    req = Req.merge(req, params: params)
    {_, resp} = Req.run(req)

    resp
  end

  defp do_request(%{method: :post} = req, params) do
    req = Req.merge(req, params: params)
    {_, resp} = Req.run(req)

    resp
  end

  defp do_request(%{method: :put} = req, params) do
    req = Req.merge(req, params: params)
    {_, resp} = Req.run(req)

    resp
  end

  defp do_request(%{method: :delete} = req, params) do
    req = Req.merge(req, params: params)
    {_, resp} = Req.request(req)

    resp
  end
end