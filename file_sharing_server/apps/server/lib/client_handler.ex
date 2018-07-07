defmodule Server.ClientHandler do
  use GenServer

  def start_link(init_args) do
    # you may want to register your server with `name: __MODULE__`
    # as a third argument to `start_link`
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(args) do
    client = args[:client]
    key = args[:key]

    {:ok, %{key: key, client: client}}
  end

  def handle_call({:get_files, key: key, directory: directory}, _from, %{client: client} = _state) do
    Server.DBHandler.get_files(key)
    |> String.split(", ")
    |> Enum.map(
      Node.spawn(:"#{client}", fn path_to_file ->
        {:ok, file} = File.open(directory, [:write])
        IO.binwrite(file, :zlib.gzip(path_to_file))
        File.close(file)
        {:ok}
      end)
    )
  end

  def handle_call(
        {:update_files, key: key, directory: directory, last_update: last_update},
        _from,
        %{client: client} = _state
      ) do
    server_update = Server.DBHandler.get_timestamp(key) |> DateTime.to_unix()

    case DateTime.compare(server_update, last_update) do
      :gt ->
        Server.DBHandler.get_files(key)
        |> String.split(", ")
        |> Enum.map(
          Node.spawn(:"#{client}", fn path_to_file ->
            {:ok, file} = File.open(directory, [:write])
            IO.binwrite(file, :zlib.gzip(path_to_file))
            File.close(file)
            {:ok}
          end)
        )

      _ ->
        Node.spawn(:"#{client}", fn -> IO.puts("files are up to date") end)
    end
  end
end
