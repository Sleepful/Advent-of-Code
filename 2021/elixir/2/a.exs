import String

IO.stream()
|> Stream.map(&(&1
  |> String.split
  |> then(fn [h, t] -> [h, to_integer(t)] end)))
|> Stream.transform({0, 0}, fn [dir, n], {x, y} ->
  case dir do
    "forward" ->
      {x, y} = {x+n, y}
      {[x*y],{x,y}}
    "down" ->
      {x, y} = {x, y+n}
      {[x*y],{x,y}}
    "up" ->
      {x, y} = {x, y-n}
      {[x*y],{x,y}}
  end
end)
|> Stream.take(-1)
|> Enum.each(&IO.inspect&1)

# cat input | elixir a.exs
