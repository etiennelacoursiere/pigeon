defmodule Pigeon.Monitoring.Monitor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "monitors" do
    field :name, :string
    field :url, :string
    field :status, Ecto.Enum, values: [:up, :down], default: :down

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
    monitor
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
