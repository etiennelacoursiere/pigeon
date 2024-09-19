defmodule PigeonWeb.Utils.Time do
  def format_duration(%Timex.Duration{} = duration) do
    duration
    |> Timex.format_duration(:humanized)
    |> abbreviate_duration()
  end

  # TODO: Implement a better solution this is extremely stupid.
  # Probably implement a Timex Formatter
  def abbreviate_duration(duration) do
    regex = ~r/(\d+)\s*(second|minute|hour|day|week|month|year)s?/i

    abbreviations = %{
      "second" => "s",
      "minute" => "m",
      "hour" => "h",
      "day" => "d",
      "week" => "w",
      "month" => "mo",
      "year" => "y"
    }

    Regex.replace(regex, duration, fn _, value, unit ->
      abbreviated_unit = Map.get(abbreviations, String.downcase(unit), unit)
      "#{value}#{abbreviated_unit}"
    end)
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end
