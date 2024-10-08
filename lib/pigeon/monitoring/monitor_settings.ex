defmodule Pigeon.Monitoring.MonitorSettings do
  use Ecto.Schema
  import Ecto.Changeset

  schema "monitor_settings" do
    field :interval, :integer, default: 60
    field :check_ssl_errors, :boolean, default: false
    field :ssl_expiry_reminders, :boolean, default: false
    field :domain_expiry_reminders, :boolean, default: false

    belongs_to :monitor, Pigeon.Monitoring.Monitor

    timestamps()
  end

  def intervals, do: [60, 300, 1800, 3600, 43200, 86400]

  @optional [:interval, :check_ssl_errors, :ssl_expiry_reminders, :domain_expiry_reminders]
  def changeset(settings, attrs \\ %{}) do
    settings
    |> cast(attrs, @optional)
    |> validate_required(@optional)

    # TODO: Validate interval in intervals()
  end
end
