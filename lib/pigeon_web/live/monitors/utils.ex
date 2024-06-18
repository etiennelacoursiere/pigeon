defmodule PigeonWeb.Live.Monitors.Utils do
  def status_changed_at(monitor) do
    diff_date =
      case monitor.status_changed_at do
        nil -> monitor.inserted_at
        status_changed_at -> status_changed_at
      end

    NaiveDateTime.utc_now()
    |> NaiveDateTime.diff(diff_date)
    |> Timex.Duration.from_seconds()
    |> PigeonWeb.Utils.Time.format_duration()
  end

  def interval(%{settings: settings}) do
    settings.interval
    |> Timex.Duration.from_seconds()
    |> PigeonWeb.Utils.Time.format_duration()
  end
end
