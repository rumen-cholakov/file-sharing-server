defmodule Client.Parser do
  def parse(command) do
    [directive | body] =
      command
      |> String.trim()
      |> String.split(" ", parts: 2)

    call_client(directive, body)
  end

  defp call_client("get", []) do
    Client.get_files()
  end

  defp call_client("update", []) do
    Client.update_files()
  end

  defp call_client("set", key) do
    Client.set_key(key)
  end

  defp call_client("help", []) do
    manual = """
    commands:
    get
    update
    set <key>
    """

    IO.puts(manual)
  end
end
