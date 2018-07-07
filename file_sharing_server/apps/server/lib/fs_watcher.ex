defmodule Server.FSWatcher do
  def start(args) do
    :fs.start_link(:my_watcher, args[:directory])
    :fs.subscribe(:my_watcher)

    update_on_event(args[:directory])
  end

  defp update_on_event(path) do
    receive do
      {_watcher_process, {:fs, :file_event}, {_changedFile, _type}} ->
        key = Path.dirname(path)

        data =
          Path.join([path, '*'])
          |> Path.wildcard()
          |> Enum.join(", ")

        Server.DBHandler.update_row(key, data)

        update_on_event(path)
    end
  end
end
