# YGOProDeck

Elixir client for the [YGOPRODECK](https://db.ygoprodeck.com/) Yu-Gi-Oh! card database API.

## Installation

Add `ygoprodeck` to your list of dependencies in `mix.exs`, along with either Finch or Req as your HTTP client:

```elixir
def deps do
  [
    {:ygoprodeck, "~> 0.1.0"},
    {:finch, "~> 0.18"}  # or {:req, "~> 0.5"}
  ]
end
```

## Configuration

Configure your HTTP client in `config/config.exs`:

### Using Finch (recommended)

```elixir
config :ygoprodeck,
  http_client: YGOProDeck.HTTP.Finch,
  finch_name: MyApp.Finch  # Your Finch pool name
```

Add Finch to your supervision tree:

```elixir
children = [
  {Finch, name: MyApp.Finch}
]
```

### Using Req

```elixir
config :ygoprodeck,
  http_client: YGOProDeck.HTTP.Req
```

## Usage

```elixir
# Get a card by ID
{:ok, card} = YGOProDeck.get_card(89631139)

# Get a card by exact name
{:ok, card} = YGOProDeck.get_card("Blue-Eyes White Dragon")

# Search cards with parameters
{:ok, cards} = YGOProDeck.get_cards(%{fname: "Blue-Eyes", type: "Monster"})

# Get only essential fields
{:ok, card} = YGOProDeck.get_card(89631139, fields: :default)

# Get specific fields
{:ok, card} = YGOProDeck.get_card(89631139, fields: [:name, :type, :atk, :def])

# Generate gameplay summary
summary = YGOProDeck.Card.summarize(card)
```

## Error Handling

```elixir
case YGOProDeck.get_card(999999) do
  {:ok, card} -> IO.inspect(card)
  {:error, %YGOProDeck.Error{reason: :not_found}} -> IO.puts("Card not found")
  {:error, %YGOProDeck.Error{reason: :rate_limited}} -> IO.puts("Rate limited")
  {:error, error} -> IO.inspect(error)
end
```

## License

MIT - See [LICENSE](LICENSE) for details.
