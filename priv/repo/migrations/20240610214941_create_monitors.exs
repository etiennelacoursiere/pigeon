defmodule Pigeon.Repo.Migrations.CreateMonitoring do
  use Ecto.Migration

  def change do
    create table(:monitors) do
      add :name, :string
      add :url, :string
      add :status, :string

      timestamps()
    end
  end
end
