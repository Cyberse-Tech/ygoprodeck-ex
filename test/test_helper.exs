ExUnit.start()

# Start Finch for testing
{:ok, _} = Finch.start_link(name: YGOProDeck.FinchTest)

# Load test support files
Code.require_file("support/fixtures.exs", __DIR__)
Code.require_file("support/finch_test.exs", __DIR__)
