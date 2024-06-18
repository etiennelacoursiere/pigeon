defmodule Pigeon.Monitoring.Incident do
  use Ecto.Schema
  import Ecto.Changeset

  schema "incidents" do
    field :status, Ecto.Enum, values: [:resolved, :ongoing], default: :ongoing
    field :root_cause, :string
    field :resolved_on, :naive_datetime
    # field :request, :map
    # field :response, :map

    belongs_to :monitor, Pigeon.Monitoring.Monitor

    timestamps()
  end

  def new_incident_changeset(incident, attrs \\ %{}) do
    incident
    |> cast(attrs, [:monitor_id, :root_cause])
    |> validate_required([:monitor_id, :root_cause])
  end

  def resolve_incident_changeset(incident, attrs \\ %{}) do
    attrs =
      attrs
      |> Map.put_new(:status, :resolved)
      |> Map.put_new(:resolved_on, NaiveDateTime.utc_now())

    incident
    |> cast(attrs, [:status, :resolved_on])
    |> validate_required([:status, :resolved_on])
  end
end
