defmodule PigeonWeb.Utils.Time do
  def format_duration(%Timex.Duration{} = duration) do
    duration
    |> Timex.format_duration(:humanized)
    |> abbreviate_duration()
  end

  # TODO: Implement a better solution this is extremely stupid.
  # Probably implement a Timex Formatter
  def abbreviate_duration(duration) do
    duration
    |> String.replace("seconds", "s")
    |> String.replace("second", "s")
    |> String.replace("minutes", "m")
    |> String.replace("minute", "m")
    |> String.replace("hours", "h")
    |> String.replace("hour", "h")
    |> String.replace("days", "d")
    |> String.replace("day", "d")
    |> String.replace("weeks", "w")
    |> String.replace("week", "w")
    |> String.replace("months", "mo")
    |> String.replace("month", "mo")
    |> String.replace("years", "y")
    |> String.replace("year", "y")
    |> String.replace(" ", "")
    |> String.replace(",", " ")
  end
end
