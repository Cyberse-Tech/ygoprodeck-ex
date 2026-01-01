defmodule YGOProDeck.Client do
  @moduledoc """
  HTTP client for the YGOPRODECK API.

  Provides functions to fetch card data by ID, name, or search parameters.
  """

  alias YGOProDeck.{Card, Error}

  @base_url "https://db.ygoprodeck.com/api/v7/cardinfo.php"

  @doc """
  Get a card by ID (integer) or exact name (string).

  ## Options

    * `:fields` - Filter fields (`:default` for essential fields, or list of atoms)
    * `:http_client` - HTTP client module (default: from config)
    * `:timeout` - Request timeout in ms (default: 10_000)
    * `:finch_name` - Finch pool name (if using Finch)

  ## Examples

      {:ok, card} = YGOProDeck.Client.get_card(89631139)
      {:ok, card} = YGOProDeck.Client.get_card("Blue-Eyes White Dragon")
      {:ok, card} = YGOProDeck.Client.get_card(89631139, fields: :default)
      {:ok, card} = YGOProDeck.Client.get_card(89631139, fields: [:name, :atk, :def])

  ## Errors

  Returns `{:error, %YGOProDeck.Error{}}` with reasons:
    * `:not_found` - Card not found
    * `:rate_limited` - API rate limit exceeded
    * `:api_error` - API returned an error
    * `:network_error` - Network or connection error
  """
  @spec get_card(integer() | String.t(), keyword()) ::
          {:ok, Card.t()} | {:error, Error.t()}
  def get_card(id, opts \\ [])

  def get_card(id, opts) when is_integer(id) do
    fetch_card(%{id: id}, opts)
  end

  def get_card(name, opts) when is_binary(name) do
    fetch_card(%{name: name}, opts)
  end

  @doc """
  Search cards with parameters.

  ## Parameters

    * `:id` - Card ID
    * `:name` - Exact card name
    * `:fname` - Fuzzy name search
    * `:type` - Card type filter
    * `:race` - Race/spell type filter
    * `:attribute` - Attribute filter
    * `:archetype` - Archetype filter
    * `:level` - Level/Rank filter
    * `:atk` / `:def` - ATK/DEF filter

  ## Options

  Same as `get_card/2`.

  ## Examples

      {:ok, cards} = YGOProDeck.Client.get_cards(%{fname: "Blue-Eyes"})
      {:ok, cards} = YGOProDeck.Client.get_cards(%{type: "Spell Card", race: "Normal"})
      {:ok, cards} = YGOProDeck.Client.get_cards(%{attribute: "DARK", level: 4})
  """
  @spec get_cards(map(), keyword()) ::
          {:ok, [Card.t()]} | {:error, Error.t()}
  def get_cards(params, opts \\ []) when is_map(params) do
    with {:ok, body} <- http_get(build_url(params), opts),
         {:ok, data} <- parse_response(body) do
      cards =
        data
        |> Enum.map(&Card.from_api/1)
        |> maybe_filter_fields(opts[:fields])

      {:ok, cards}
    end
  end

  # Private helpers

  defp fetch_card(params, opts) do
    with {:ok, body} <- http_get(build_url(params), opts),
         {:ok, [data | _]} <- parse_response(body) do
      card =
        data
        |> Card.from_api()
        |> maybe_filter_fields(opts[:fields])

      {:ok, card}
    else
      {:ok, []} -> {:error, Error.new(:not_found)}
      error -> error
    end
  end

  defp http_get(url, opts) do
    http_client = opts[:http_client] || Application.get_env(:ygoprodeck, :http_client)

    unless http_client do
      raise ArgumentError, """
      HTTP client not configured. Please set in config.exs:

          config :ygoprodeck, http_client: YGOProDeck.HTTP.Finch
      """
    end

    case http_client.get(url, opts) do
      {:ok, body} -> {:ok, body}
      {:error, :not_found} -> {:error, Error.new(:not_found)}
      {:error, :rate_limited} -> {:error, Error.new(:rate_limited)}
      {:error, {:api_error, msg}} -> {:error, Error.new(:api_error, msg)}
      {:error, {:network_error, msg}} -> {:error, Error.new(:network_error, msg)}
      {:error, reason} -> {:error, Error.new(:network_error, inspect(reason))}
    end
  end

  defp parse_response(body) do
    case Jason.decode(body) do
      {:ok, %{"data" => data}} when is_list(data) ->
        {:ok, data}

      {:ok, %{"error" => error_msg}} ->
        {:error, Error.new(:not_found, error_msg)}

      {:error, _} ->
        {:error, Error.new(:api_error, "Failed to parse API response")}
    end
  end

  defp build_url(params) do
    query =
      params
      |> Enum.map(fn {k, v} -> "#{k}=#{URI.encode_www_form(to_string(v))}" end)
      |> Enum.join("&")

    "#{@base_url}?#{query}"
  end

  defp maybe_filter_fields(card_or_cards, nil), do: card_or_cards

  defp maybe_filter_fields(cards, fields) when is_list(cards) do
    Enum.map(cards, &Card.filter_fields(&1, fields))
  end

  defp maybe_filter_fields(card, fields) do
    Card.filter_fields(card, fields)
  end
end
