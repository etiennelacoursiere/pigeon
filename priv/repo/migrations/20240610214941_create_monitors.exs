defmodule Pigeon.Repo.Migrations.CreateMonitoring do
  use Ecto.Migration

  def change do
    create table(:monitors) do
      add :name, :string
      add :url, :string, null: false
      add :status, :string
      add :status_changed_at, :naive_datetime

      timestamps()
    end
  end
end
