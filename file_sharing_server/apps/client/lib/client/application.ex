defmodule Client.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @default_name 'server'
  @default_location 'localhost'
  @default_client_name 'client'
  @default_directory Path.expand("~/file_dir")

  def start(_type, _args) do
    server_name = Application.get_env(:client, :server_name, @default_name)

    server_location = Application.get_env(:client, :server_location, @default_location)

    dir = Application.get_env(:client, :file_directory, @default_directory)

    client_name = Application.get_env(:client, :client_name, @default_client_name)

    # List all child processes to be supervised
    children = [
      {Client.CLI.Worker, :start},
      {Client.Worker,
       [[name: server_name, location: server_location, directory: dir, client_name: client_name]]},
      {Task.Supervisor, [[name: :tasks_supervisor]]}
      # Starts a worker by calling: Client.Worker.start_link(arg)
      # {Client.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Client.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
