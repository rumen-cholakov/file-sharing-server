defmodule Server do
  use GenServer

  def start_link(init_args) do
    # you may want to register your server with `name: __MODULE__`
    # as a third argument to `start_link`
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(args) do
    name = args[:server_name]
    location = args[:server_location]

    case Node.start(:"#{name}", :shortnames) do
      {:ok, _} ->
        {:ok, %{name: name, location: location}}

      {:error, err_msg} ->
        {:error, err_msg}
    end
  end

  def handle_call({:create_connection, client: client, key: key}, _from, state) do
    DynamicSupervisor.start_child(Server.DynamicSupervisor, %{
      id: Server.ClientHandler.Worker,
      start: {Server.ClientHandler, :start_link, [[client: client, key: key]]}
    })

    {:ok, state}
  end

  def add_key(key) do
    Server.DBHandler.add_row(key)
  end
end
