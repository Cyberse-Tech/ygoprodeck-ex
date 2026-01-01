defmodule YGOProDeck.HTTP.FinchTest do
  @moduledoc """
  Test HTTP adapter that uses Bypass for mocking.
  """

  @behaviour YGOProDeck.HTTP

  @impl true
  def get(url, _opts \\ []) do
    # Replace the base URL with the bypass URL for testing
    bypass_url = Application.get_env(:ygoprodeck, :bypass_url)
    test_url = String.replace(url, "https://db.ygoprodeck.com", bypass_url)

    request = Finch.build(:get, test_url)

    case Finch.request(request, YGOProDeck.FinchTest) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Finch.Response{status: 404}} ->
        {:error, :not_found}

      {:ok, %Finch.Response{status: 429}} ->
        {:error, :rate_limited}

      {:ok, %Finch.Response{status: status}} when status >= 500 ->
        {:error, {:api_error, "Server error #{status}"}}

      {:ok, %Finch.Response{status: status}} ->
        {:error, {:api_error, "HTTP #{status}"}}

      {:error, reason} ->
        {:error, {:network_error, inspect(reason)}}
    end
  end
end
