defmodule Server.DBHandler do
  import Ecto.Query, only: [from: 2]
  alias Server.{Repo, KeyData}

  def get_files(key) do
    query =
      from(
        row in KeyData,
        where: row.key == ^key,
        select: row.files
      )

    Repo.all(query)
  end

  def add_row(key, files) do
    changeset = KeyData.changeset(%KeyData{}, %{key: key, files: files})

    Repo.insert(changeset)
  end

  def update_row(key, files) do
    changeset = Repo.get(KeyData, key)
    changeset = Ecto.Changeset.change(changeset, files: files)

    Repo.update(changeset)
  end

  def delete_row(key) do
    changeset = Repo.get(KeyData, key)

    Repo.delete(changeset)
  end
end
