defmodule Client.CLI do
  alias Client.Parser

  def start do
    read_input()
  end

  defp read_input do
    command = IO.gets(">")

    Parser.parse(command)

    read_input()
  end
end
