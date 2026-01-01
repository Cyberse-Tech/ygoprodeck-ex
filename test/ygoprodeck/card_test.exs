defmodule YGOProDeck.CardTest do
  use ExUnit.Case
  doctest YGOProDeck.Card

  alias YGOProDeck.{Card, Fixtures}

  describe "from_api/1" do
    test "parses normal monster" do
      data = Fixtures.blue_eyes_white_dragon()
      card = Card.from_api(data)

      assert card.id == 89_631_139
      assert card.name == "Blue-Eyes White Dragon"
      assert card.type == "Normal Monster"
      assert card.frame_type == "normal"
      assert card.race == "Dragon"
      assert card.atk == 3000
      assert card.def == 2500
      assert card.level == 8
      assert card.attribute == "LIGHT"
      assert card.archetype == "Blue-Eyes"
      assert card.typeline == ["Dragon", "Normal"]
      assert is_list(card.card_sets)
      assert is_list(card.card_images)
      assert is_list(card.card_prices)
    end

    test "parses link monster" do
      data = Fixtures.decode_talker()
      card = Card.from_api(data)

      assert card.id == 1_861_629
      assert card.name == "Decode Talker"
      assert card.type == "Link Monster"
      assert card.frame_type == "link"
      assert card.atk == 2300
      assert card.link_value == 3
      assert card.link_markers == ["Top", "Bottom-Left", "Bottom-Right"]
      assert is_nil(card.def)
      assert is_nil(card.level)
    end

    test "parses spell card" do
      data = Fixtures.raigeki()
      card = Card.from_api(data)

      assert card.id == 12_580_477
      assert card.name == "Raigeki"
      assert card.type == "Spell Card"
      assert card.frame_type == "spell"
      assert card.race == "Normal"
      assert is_nil(card.atk)
      assert is_nil(card.def)
      assert is_nil(card.level)
    end
  end

  describe "summarize/1" do
    test "summarizes normal monster with nil desc" do
      card = Card.from_api(Fixtures.blue_eyes_white_dragon())
      summary = Card.summarize(card)

      assert summary.id == 89_631_139
      assert summary.name == "Blue-Eyes White Dragon"
      assert summary.type == "Normal Monster"
      assert summary.stats == "ATK 3000 / DEF 2500"
      assert summary.level == 8
      assert summary.attribute == "LIGHT"
      assert summary.race == "Dragon"
      assert is_nil(summary.desc)
    end

    test "summarizes effect monster with desc" do
      card = Card.from_api(Fixtures.decode_talker())
      summary = Card.summarize(card)

      assert summary.id == 1_861_629
      assert summary.name == "Decode Talker"
      assert summary.type == "Link Monster"
      assert summary.stats == "ATK 2300"
      assert summary.level == 3
      refute is_nil(summary.desc)
    end

    test "summarizes spell card" do
      card = Card.from_api(Fixtures.raigeki())
      summary = Card.summarize(card)

      assert summary.id == 12_580_477
      assert summary.name == "Raigeki"
      assert summary.type == "Spell Card"
      assert is_nil(summary.stats)
      assert is_nil(summary.level)
      assert summary.race == "Normal"
      refute is_nil(summary.desc)
    end
  end

  describe "filter_fields/2" do
    test "filters to default fields" do
      card = Card.from_api(Fixtures.blue_eyes_white_dragon())
      filtered = Card.filter_fields(card, :default)

      assert filtered.name == "Blue-Eyes White Dragon"
      assert filtered.atk == 3000
      assert is_nil(filtered.card_sets)
      assert is_nil(filtered.card_prices)
      assert is_nil(filtered.card_images)
    end

    test "filters to custom fields" do
      card = Card.from_api(Fixtures.blue_eyes_white_dragon())
      filtered = Card.filter_fields(card, [:name, :atk, :def])

      assert filtered.name == "Blue-Eyes White Dragon"
      assert filtered.atk == 3000
      assert filtered.def == 2500
      assert is_nil(filtered.id)
      assert is_nil(filtered.level)
      assert is_nil(filtered.card_sets)
    end
  end
end
