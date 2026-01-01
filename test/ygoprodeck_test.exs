defmodule YGOProDeckTest do
  use ExUnit.Case
  doctest YGOProDeck

  alias YGOProDeck.{Error, Fixtures}

  setup do
    bypass = Bypass.open()
    Application.put_env(:ygoprodeck, :http_client, YGOProDeck.HTTP.FinchTest)
    Application.put_env(:ygoprodeck, :bypass_url, "http://localhost:#{bypass.port}")
    {:ok, bypass: bypass}
  end

  describe "get_card/2 by ID" do
    test "fetches card successfully", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/api/v7/cardinfo.php", fn conn ->
        conn = Plug.Conn.fetch_query_params(conn)
        assert conn.params["id"] == "89631139"
        Plug.Conn.resp(conn, 200, Fixtures.blue_eyes_response())
      end)

      assert {:ok, card} = YGOProDeck.get_card(89_631_139)
      assert card.name == "Blue-Eyes White Dragon"
      assert card.atk == 3000
      assert card.def == 2500
      assert card.level == 8
      assert card.attribute == "LIGHT"
    end

    test "returns not_found for invalid ID", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/api/v7/cardinfo.php", fn conn ->
        Plug.Conn.resp(conn, 200, Fixtures.not_found_response())
      end)

      assert {:error, %Error{reason: :not_found}} = YGOProDeck.get_card(999_999_999)
    end
  end

  describe "get_card/2 by name" do
    test "fetches card by exact name", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/api/v7/cardinfo.php", fn conn ->
        conn = Plug.Conn.fetch_query_params(conn)
        assert conn.params["name"] == "Blue-Eyes White Dragon"
        Plug.Conn.resp(conn, 200, Fixtures.blue_eyes_response())
      end)

      assert {:ok, card} = YGOProDeck.get_card("Blue-Eyes White Dragon")
      assert card.id == 89_631_139
      assert card.name == "Blue-Eyes White Dragon"
    end

    test "handles URL encoding in names", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/api/v7/cardinfo.php", fn conn ->
        conn = Plug.Conn.fetch_query_params(conn)
        assert conn.params["name"] == "Pot of Greed"
        Plug.Conn.resp(conn, 200, Fixtures.blue_eyes_response())
      end)

      assert {:ok, _card} = YGOProDeck.get_card("Pot of Greed")
    end
  end

  describe "get_card/2 with field filtering" do
    test "filters to default fields", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/api/v7/cardinfo.php", fn conn ->
        Plug.Conn.resp(conn, 200, Fixtures.blue_eyes_response())
      end)

      assert {:ok, card} = YGOProDeck.get_card(89_631_139, fields: :default)
      assert card.name == "Blue-Eyes White Dragon"
      assert card.atk == 3000
      assert is_nil(card.card_sets)
      assert is_nil(card.card_prices)
      assert is_nil(card.card_images)
    end

    test "filters to custom fields", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/api/v7/cardinfo.php", fn conn ->
        Plug.Conn.resp(conn, 200, Fixtures.blue_eyes_response())
      end)

      assert {:ok, card} = YGOProDeck.get_card(89_631_139, fields: [:name, :atk, :def])
      assert card.name == "Blue-Eyes White Dragon"
      assert card.atk == 3000
      assert card.def == 2500
      assert is_nil(card.id)
      assert is_nil(card.level)
    end
  end

  describe "get_cards/2" do
    test "searches cards by fuzzy name", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/api/v7/cardinfo.php", fn conn ->
        conn = Plug.Conn.fetch_query_params(conn)
        assert conn.params["fname"] == "Blue-Eyes"
        Plug.Conn.resp(conn, 200, Fixtures.search_response())
      end)

      assert {:ok, cards} = YGOProDeck.get_cards(%{fname: "Blue-Eyes"})
      assert length(cards) == 2
      assert Enum.any?(cards, &(&1.name == "Blue-Eyes White Dragon"))
    end

    test "searches with multiple parameters", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/api/v7/cardinfo.php", fn conn ->
        conn = Plug.Conn.fetch_query_params(conn)
        assert conn.params["type"] == "Monster"
        assert conn.params["attribute"] == "LIGHT"
        Plug.Conn.resp(conn, 200, Fixtures.search_response())
      end)

      assert {:ok, cards} = YGOProDeck.get_cards(%{type: "Monster", attribute: "LIGHT"})
      assert is_list(cards)
    end

    test "applies field filtering to search results", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/api/v7/cardinfo.php", fn conn ->
        Plug.Conn.resp(conn, 200, Fixtures.search_response())
      end)

      assert {:ok, cards} = YGOProDeck.get_cards(%{fname: "Blue"}, fields: :default)
      assert length(cards) == 2

      Enum.each(cards, fn card ->
        assert is_nil(card.card_sets)
        assert is_nil(card.card_prices)
      end)
    end
  end

  describe "error handling" do
    test "handles 404 response", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/api/v7/cardinfo.php", fn conn ->
        Plug.Conn.resp(conn, 404, "Not Found")
      end)

      assert {:error, %Error{reason: :not_found}} = YGOProDeck.get_card(0)
    end

    test "handles 429 rate limit", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/api/v7/cardinfo.php", fn conn ->
        Plug.Conn.resp(conn, 429, "Rate Limit Exceeded")
      end)

      assert {:error, %Error{reason: :rate_limited}} = YGOProDeck.get_card(89_631_139)
    end

    test "handles 500 server error", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/api/v7/cardinfo.php", fn conn ->
        Plug.Conn.resp(conn, 500, "Internal Server Error")
      end)

      assert {:error, %Error{reason: :api_error}} = YGOProDeck.get_card(89_631_139)
    end

    test "handles network errors", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %Error{reason: :network_error}} = YGOProDeck.get_card(89_631_139)
    end
  end
end
