defmodule Server.CLI do
  alias Server.Parser

  def start do
    read_input()
  end

  defp read_input do
    command = IO.gets(">")

    Parser.parse(command)

    read_input()
  end
end
