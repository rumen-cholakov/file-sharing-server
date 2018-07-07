defmodule Server.Parser do
  def parse(command) do
    [directive | body] =
      command
      |> String.trim()
      |> String.split(" ", parts: 2)

    call_server(directive, body)
  end

  defp call_server("add", [key]) do
    Server.add_key(key)
  end

  defp call_server("help", []) do
    manual = """
    commands:
    add <key>
    """

    IO.puts(manual)
  end
end
