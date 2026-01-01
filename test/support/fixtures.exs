defmodule YGOProDeck.Fixtures do
  @moduledoc """
  API response fixtures for testing.
  """

  def blue_eyes_white_dragon do
    %{
      "id" => 89_631_139,
      "name" => "Blue-Eyes White Dragon",
      "type" => "Normal Monster",
      "frameType" => "normal",
      "desc" =>
        "This legendary dragon is a powerful engine of destruction. Virtually invincible, very few have faced this awesome creature and lived to tell the tale.",
      "race" => "Dragon",
      "atk" => 3000,
      "def" => 2500,
      "level" => 8,
      "attribute" => "LIGHT",
      "archetype" => "Blue-Eyes",
      "typeline" => ["Dragon", "Normal"],
      "card_sets" => [
        %{
          "set_name" => "Legend of Blue Eyes White Dragon",
          "set_code" => "LOB-001",
          "set_rarity" => "Ultra Rare"
        }
      ],
      "card_images" => [
        %{
          "id" => 89_631_139,
          "image_url" => "https://images.ygoprodeck.com/images/cards/89631139.jpg",
          "image_url_small" => "https://images.ygoprodeck.com/images/cards_small/89631139.jpg"
        }
      ],
      "card_prices" => [
        %{
          "cardmarket_price" => "1.50",
          "tcgplayer_price" => "2.00",
          "ebay_price" => "1.75"
        }
      ]
    }
  end

  def blue_eyes_response do
    Jason.encode!(%{"data" => [blue_eyes_white_dragon()]})
  end

  def decode_talker do
    %{
      "id" => 1_861_629,
      "name" => "Decode Talker",
      "type" => "Link Monster",
      "frameType" => "link",
      "desc" =>
        "2+ Effect Monsters\nGains 500 ATK for each monster it points to. When your opponent activates a card or effect while you control this Link Summoned monster (Quick Effect): You can Tribute 1 monster this card points to; negate the activation, and if you do, destroy that card.",
      "race" => "Cyberse",
      "atk" => 2300,
      "linkval" => 3,
      "linkmarkers" => ["Top", "Bottom-Left", "Bottom-Right"],
      "typeline" => ["Cyberse", "Link", "Effect"]
    }
  end

  def decode_talker_response do
    Jason.encode!(%{"data" => [decode_talker()]})
  end

  def raigeki do
    %{
      "id" => 12_580_477,
      "name" => "Raigeki",
      "type" => "Spell Card",
      "frameType" => "spell",
      "desc" => "Destroy all monsters your opponent controls.",
      "race" => "Normal",
      "typeline" => ["Spell", "Normal"]
    }
  end

  def raigeki_response do
    Jason.encode!(%{"data" => [raigeki()]})
  end

  def not_found_response do
    Jason.encode!(%{
      "error" =>
        "No card matching your query was found in the database. Please see https://db.ygoprodeck.com/api-guide/ for syntax usage."
    })
  end

  def search_results do
    [blue_eyes_white_dragon(), decode_talker()]
  end

  def search_response do
    Jason.encode!(%{"data" => search_results()})
  end
end
