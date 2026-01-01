defmodule YGOProDeck.HTTP.Req do
  @moduledoc """
  Req HTTP client adapter for YGOPRODECK API.

  ## Configuration

      config :ygoprodeck,
        http_client: YGOProDeck.HTTP.Req
  """

  @behaviour YGOProDeck.HTTP

  @impl true
  def get(url, opts \\ []) do
    timeout = opts[:timeout] || 10_000

    case Req.get(url, receive_timeout: timeout) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Req.Response{status: 404}} ->
        {:error, :not_found}

      {:ok, %Req.Response{status: 429}} ->
        {:error, :rate_limited}

      {:ok, %Req.Response{status: status, body: body}} when status >= 500 ->
        {:error, {:api_error, "Server error #{status}: #{body}"}}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:api_error, "HTTP #{status}: #{body}"}}

      {:error, %Mint.TransportError{reason: reason}} ->
        {:error, {:network_error, "Transport error: #{inspect(reason)}"}}

      {:error, exception} when is_exception(exception) ->
        {:error, {:network_error, Exception.message(exception)}}

      {:error, reason} ->
        {:error, {:network_error, inspect(reason)}}
    end
  end
end
