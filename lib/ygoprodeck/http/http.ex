defmodule YGOProDeck.HTTP do
  @moduledoc """
  Behaviour for HTTP client adapters.

  This allows the library to support multiple HTTP clients (Finch, Req)
  while keeping the implementation pluggable.
  """

  @doc """
  Perform a GET request to the given URL.

  Returns `{:ok, body}` on success or `{:error, reason}` on failure.
  """
  @callback get(url :: String.t(), opts :: keyword()) ::
              {:ok, body :: String.t()} | {:error, term()}
end
