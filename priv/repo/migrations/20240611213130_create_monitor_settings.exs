defmodule Pigeon.Repo.Migrations.CreateMonitorSettings do
  use Ecto.Migration

  def change do
    create table(:monitor_settings) do
      add :monitor_id, references(:monitors, on_delete: :delete_all)
      add :interval, :integer
      add :check_ssl_errors, :boolean
      add :ssl_expiry_reminders, :boolean
      add :domain_expiry_reminders, :boolean

      timestamps()
    end
  end
end
