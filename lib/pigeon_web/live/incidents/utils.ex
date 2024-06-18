defmodule PigeonWeb.Live.Incidents.Utils do
  def duration(incident) do
    diff_date =
      case incident.resolved_on do
        nil -> NaiveDateTime.utc_now()
        resolved_on -> resolved_on
      end

    diff_date
    |> NaiveDateTime.diff(incident.inserted_at)
    |> Timex.Duration.from_seconds()
    |> PigeonWeb.Utils.Time.format_duration()
  end

  def started_at(user, incident) do
    tz = Map.get(user, :timezone, "UTC")

    incident
    |> Timex.Timezone.convert(tz)
    |> Timex.format!("{Mshort} {D} {YYYY} {h24}:{m} {Zname}")
  end
end
