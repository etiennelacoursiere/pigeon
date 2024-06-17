defmodule Pigeon.Monitoring.Monitor do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses [:up, :down, :paused]
  def statuses(), do: @statuses

  schema "monitors" do
    field :name, :string
    field :url, :string
    field :status, Ecto.Enum, values: @statuses, default: :paused
    field :status_changed_at, :naive_datetime

    has_one :settings, Pigeon.Monitoring.MonitorSettings

    timestamps()
  end

  @required [:name, :url]
  def changeset(monitor, attrs \\ %{}) do
    monitor
    |> cast(attrs, @required)
    |> cast_assoc(:settings)
    |> validate_required(@required)
  end

  def status_changeset(monitor, attrs) do
    attrs = Map.put(attrs, :status_changed_at, NaiveDateTime.utc_now())

    monitor
    |> cast(attrs, [:status, :status_changed_at])
    |> validate_required([:status, :status_changed_at])
  end

  def time_since_last_status_change(%{status_changed_at: status_changed_at})
      when not is_nil(status_changed_at) do
    NaiveDateTime.diff(NaiveDateTime.utc_now(), status_changed_at)
  end

  def time_since_last_status_change(%{inserted_at: inserted_at}) do
    NaiveDateTime.diff(NaiveDateTime.utc_now(), inserted_at)
  end
end
