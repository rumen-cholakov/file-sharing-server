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

  def get_timestamp(key) do
    query =
      from(
        row in KeyData,
        where: row.key == ^key,
        select: row.timestamp
      )

    Repo.all(query)
  end

  def add_row(path) do
    key = Path.dirname(path)

    files =
      Path.join([path, '*'])
      |> Path.wildcard()
      |> Enum.join(", ")

    DynamicSupervisor.start_child(Server.DynamicSupervisor, %{
      id: Server.FSWatcher.Worker,
      start: {Server.FSWatcher, :start, [[path]]}
    })

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
