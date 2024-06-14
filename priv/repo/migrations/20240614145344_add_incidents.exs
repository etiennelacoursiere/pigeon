defmodule Pigeon.Repo.Migrations.AddIncidents do
  use Ecto.Migration

  def change do
    create table(:incidents) do
      add :monitor_id, references(:monitors, on_delete: :delete_all)
      add :status, :string
      add :root_cause, :string
      add :resolved_on, :naive_datetime
      add :request, :map
      add :response, :map

      timestamps()
    end
  end
end
