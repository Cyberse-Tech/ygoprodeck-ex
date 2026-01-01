defmodule YGOProDeck.Card do
  @moduledoc """
  Struct representing a Yu-Gi-Oh! card from the YGOPRODECK API.
  """

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          type: String.t(),
          frame_type: String.t(),
          desc: String.t(),
          race: String.t(),
          attribute: String.t() | nil,
          atk: integer() | nil,
          def: integer() | nil,
          level: integer() | nil,
          rank: integer() | nil,
          link_value: integer() | nil,
          link_markers: [String.t()] | nil,
          scale: integer() | nil,
          archetype: String.t() | nil,
          typeline: [String.t()],
          card_sets: [map()] | nil,
          card_images: [map()] | nil,
          card_prices: [map()] | nil
        }

  defstruct [
    :id,
    :name,
    :type,
    :frame_type,
    :desc,
    :race,
    :attribute,
    :atk,
    :def,
    :level,
    :rank,
    :link_value,
    :link_markers,
    :scale,
    :archetype,
    :typeline,
    :card_sets,
    :card_images,
    :card_prices
  ]

  @doc """
  Parse API response data into a Card struct.

  ## Examples

      iex> data = %{"id" => 89631139, "name" => "Blue-Eyes White Dragon", "type" => "Normal Monster", "frameType" => "normal", "desc" => "desc", "race" => "Dragon", "atk" => 3000, "def" => 2500, "level" => 8, "typeline" => ["Dragon"]}
      iex> card = YGOProDeck.Card.from_api(data)
      iex> card.name
      "Blue-Eyes White Dragon"
      iex> card.atk
      3000
  """
  @spec from_api(map()) :: t()
  def from_api(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      name: data["name"],
      type: data["type"],
      frame_type: data["frameType"],
      desc: data["desc"],
      race: data["race"],
      attribute: data["attribute"],
      atk: data["atk"],
      def: data["def"],
      level: data["level"],
      rank: data["rank"],
      link_value: data["linkval"],
      link_markers: data["linkmarkers"],
      scale: data["scale"],
      archetype: data["archetype"],
      typeline: data["typeline"] || [],
      card_sets: data["card_sets"],
      card_images: data["card_images"],
      card_prices: data["card_prices"]
    }
  end

  @doc """
  Create a summary map with essential gameplay fields.

  Non-effect monsters (Normal Monster, Normal Tuner Monster, Token) have their
  description nulled since it's purely aesthetic.

  ## Examples

      iex> card = %YGOProDeck.Card{id: 89631139, name: "Blue-Eyes White Dragon", type: "Normal Monster", atk: 3000, def: 2500, level: 8, attribute: "LIGHT", race: "Dragon", desc: "desc", typeline: []}
      iex> summary = YGOProDeck.Card.summarize(card)
      iex> summary.name
      "Blue-Eyes White Dragon"
      iex> summary.stats
      "ATK 3000 / DEF 2500"
      iex> summary.desc
      nil
  """
  @spec summarize(t()) :: map()
  def summarize(%__MODULE__{} = card) do
    %{
      id: card.id,
      name: card.name,
      type: card.type,
      stats: format_stats(card),
      level: card.level || card.rank || card.link_value,
      attribute: card.attribute,
      race: card.race,
      desc: format_desc(card)
    }
  end

  defp format_stats(%{atk: atk, def: def_val}) when not is_nil(atk) and not is_nil(def_val) do
    "ATK #{atk} / DEF #{def_val}"
  end

  defp format_stats(%{atk: atk}) when not is_nil(atk), do: "ATK #{atk}"
  defp format_stats(_), do: nil

  # Null description for non-effect monsters
  defp format_desc(%{type: type})
       when type in ["Normal Monster", "Normal Tuner Monster", "Token"] do
    nil
  end

  defp format_desc(%{desc: desc}), do: desc

  @doc """
  Filter card fields based on the fields option.

  ## Options

    * `:default` - Returns only essential gameplay fields (excludes card_sets, card_prices, card_images)
    * List of atoms - Returns only the specified fields
  """
  @spec filter_fields(t(), :default | [atom()]) :: t()
  def filter_fields(%__MODULE__{} = card, :default) do
    filter_fields(card, default_fields())
  end

  def filter_fields(%__MODULE__{} = card, fields) when is_list(fields) do
    card
    |> Map.from_struct()
    |> Map.take(fields)
    |> then(&struct!(__MODULE__, &1))
  end

  defp default_fields do
    [
      :id,
      :name,
      :type,
      :frame_type,
      :desc,
      :race,
      :attribute,
      :atk,
      :def,
      :level,
      :rank,
      :link_value,
      :link_markers,
      :scale,
      :archetype,
      :typeline
    ]
  end
end
