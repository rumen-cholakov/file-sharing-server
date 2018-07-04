defmodule Server.Repo.Migrations.KeyData do
  use Ecto.Migration

  def change do
    create table(:key_data) do
      add(:key, :string, unique: true)
      add(:files, :string, null: false)

      timestamps
  end

  create(unique_index(:key_data, [:key], name: :unique_keys))
end
