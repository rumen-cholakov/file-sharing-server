defmodule Client do
  use GenServer

  @default_key ''
  @default_time 0

  # @default_dir Path.expand("~/target")

  def start_link(init_args) do
    # you may want to register your server with `name: __MODULE__`
    # as a third argument to `start_link`
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(args) do
    server_name = args[:name]
    server_location = args[:location]
    client_name = args[:client_name]
    key = @default_key
    last_update = @default_time
    file_directory = args[:directory]

    case Node.start(:"#{client_name}", :shortnames) do
      {:ok, _} ->
        case Node.connect(:"#{server_name}@#{server_location}") do
          true ->
            node_id = Node.self()

            {:ok,
             %{
               server_name: server_name,
               server_location: server_location,
               key: key,
               last_update: last_update,
               directory: file_directory,
               node_id: node_id
             }}

          _ ->
            IO.puts("no connection to server")
            {:error, "no connection to server"}
        end

      {:error, err_msg} ->
        {:error, err_msg}
    end
  end

  def set_key(key) do
    GenServer.call(__MODULE__, {:key, key})
  end

  def get_files do
    GenServer.call(__MODULE__, {:get_files})
  end

  def update_files do
    GenServer.call(__MODULE__, {:update_files})
  end

  def handle_call({:key, new_key}, _from, state) do
    {:noreply, %{state | key: new_key}}
  end

  # TODO check server output
  def handle_call({:get_files}, _from, %{key: key, directory: directory} = state) do
    Server.get_files(key, directory)
    {:reply, "files downloaded", %{state | last_update: current_time()}}
  end

  # TODO check server output
  def handle_call(
        {:update_files},
        _from,
        %{key: key, last_update: last_update, directory: directory} = state
      ) do
    Server.update_files(key, last_update, directory)
    {:reply, %{state | last_update: current_time()}}
  end

  defp current_time do
    DateTime.utc_now()
    |> DateTime.to_unix()
  end
end
