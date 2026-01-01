defmodule YGOProDeck do
  @moduledoc """
  Elixir client for the YGOPRODECK Yu-Gi-Oh! card database API.

  ## Configuration

  Configure your HTTP client in `config/config.exs`:

      # Using Finch (recommended)
      config :ygoprodeck,
        http_client: YGOProDeck.HTTP.Finch,
        finch_name: MyApp.Finch

      # Using Req
      config :ygoprodeck,
        http_client: YGOProDeck.HTTP.Req

  ## Examples

      # Get card by ID
      {:ok, card} = YGOProDeck.get_card(89631139)

      # Get card by name
      {:ok, card} = YGOProDeck.get_card("Blue-Eyes White Dragon")

      # Search cards
      {:ok, cards} = YGOProDeck.get_cards(%{fname: "Blue-Eyes"})

      # Get only essential fields
      {:ok, card} = YGOProDeck.get_card(89631139, fields: :default)
  """

  defdelegate get_card(id_or_name, opts \\ []), to: YGOProDeck.Client
  defdelegate get_cards(params, opts \\ []), to: YGOProDeck.Client
end
