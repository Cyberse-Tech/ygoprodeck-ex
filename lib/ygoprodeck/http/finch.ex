defmodule YGOProDeck.HTTP.Finch do
  @moduledoc """
  Finch HTTP client adapter for YGOPRODECK API.

  ## Configuration

      config :ygoprodeck,
        http_client: YGOProDeck.HTTP.Finch,
        finch_name: MyApp.Finch

  You must start Finch in your supervision tree:

      children = [
        {Finch, name: MyApp.Finch}
      ]
  """

  @behaviour YGOProDeck.HTTP

  @impl true
  def get(url, opts \\ []) do
    finch_name = opts[:finch_name] || Application.get_env(:ygoprodeck, :finch_name)
    timeout = opts[:timeout] || 10_000

    unless finch_name do
      raise ArgumentError, """
      Finch pool name not configured. Please set in config.exs:

          config :ygoprodeck, finch_name: MyApp.Finch
      """
    end

    request = Finch.build(:get, url)

    case Finch.request(request, finch_name, receive_timeout: timeout) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Finch.Response{status: 404}} ->
        {:error, :not_found}

      {:ok, %Finch.Response{status: 429}} ->
        {:error, :rate_limited}

      {:ok, %Finch.Response{status: status, body: body}} when status >= 500 ->
        {:error, {:api_error, "Server error #{status}: #{body}"}}

      {:ok, %Finch.Response{status: status, body: body}} ->
        {:error, {:api_error, "HTTP #{status}: #{body}"}}

      {:error, %Mint.TransportError{reason: reason}} ->
        {:error, {:network_error, "Transport error: #{inspect(reason)}"}}

      {:error, reason} ->
        {:error, {:network_error, inspect(reason)}}
    end
  end
end
