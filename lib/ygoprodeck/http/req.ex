defmodule YGOProDeck.HTTP.Req do
  @moduledoc """
  Req HTTP client adapter for YGOPRODECK API.

  ## Configuration

      config :ygoprodeck,
        http_client: YGOProDeck.HTTP.Req

  Requires the `req` package to be installed.
  """

  @behaviour YGOProDeck.HTTP

  @impl true
  def get(url, opts \\ []) do
    unless Code.ensure_loaded?(Req) do
      raise ArgumentError, """
      Req is not installed. Please add to your deps:

          {:req, "~> 0.5"}
      """
    end

    timeout = opts[:timeout] || 10_000

    case Req.get(url, receive_timeout: timeout) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: 404}} ->
        {:error, :not_found}

      {:ok, %{status: 429}} ->
        {:error, :rate_limited}

      {:ok, %{status: status, body: body}} when status >= 500 ->
        {:error, {:api_error, "Server error #{status}: #{body}"}}

      {:ok, %{status: status, body: body}} ->
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
