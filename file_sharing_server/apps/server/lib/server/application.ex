defmodule Server.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @default_name 'server'
  @default_location 'localhost'
  def start(_type, _args) do
    server_name = Application.get_env(:server, :server_name, @default_name)
    server_location = Application.get_env(:server, :server_location, @default_location)
    # List all child processes to be supervised
    children = [
      Server.Repo,
      {DynamicSupervisor, name: Server.DynamicSupervisor, strategy: :one_for_one},
      %{
        id: Server.Worker,
        start:
          {Server, :start_link,
           [
             [
               name: server_name,
               location: server_location
             ]
           ]}
      }
      # Starts a worker by calling: Server.Worker.start_link(arg)
      # {Server.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Server.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
