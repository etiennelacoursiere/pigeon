defmodule Pigeon.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :tz, :string

    timestamps()
  end

  @required [:name, :email]
  def changeset(monitor, attrs \\ %{}) do
    monitor
    |> cast(attrs, @required)
    |> validate_required(@required)
  end
end
