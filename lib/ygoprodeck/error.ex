defmodule YGOProDeck.Error do
  @moduledoc """
  Exception struct for YGOPRODECK API errors.
  """

  defexception [:reason, :message]

  @type t :: %__MODULE__{
          reason: :not_found | :rate_limited | :api_error | :network_error,
          message: String.t()
        }

  @doc """
  Creates a new error with the given reason and optional message.
  """
  @spec new(atom(), String.t() | nil) :: t()
  def new(reason, message \\ nil) do
    %__MODULE__{
      reason: reason,
      message: message || default_message(reason)
    }
  end

  defp default_message(:not_found), do: "Card not found"
  defp default_message(:rate_limited), do: "API rate limit exceeded"
  defp default_message(:api_error), do: "API error"
  defp default_message(:network_error), do: "Network error"
  defp default_message(_), do: "Unknown error"
end
