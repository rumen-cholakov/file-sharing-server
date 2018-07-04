defmodule Server.KeyData do
  use Ecto.Schema
  import Ecto.Changeset

  schema "key_data" do
    field(:key, :string)
    field(:files, :string)

    timestamps
  end

  @required_fields ~w(key files)
  @optional_fields ~w()

  def changeset(key_data, params \\ :empty) do
    key_data
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:key)
  end
end
