IO.stream()
|> Stream.map(fn n -> {i, _} = Integer.parse(n); i end)
|> Stream.chunk_every(2,1, :discard)
|> Stream.transform(0, fn [h, t], acc ->
  cond do
    h < t ->
      {[acc + 1],  acc + 1}
    true ->
      {[nil], acc}
  end
end)
|> Stream.filter(&!is_nil&1)
|> Stream.take(-1)
|> Enum.each(&IO.puts&1)

# cat input | elixir a.exs
