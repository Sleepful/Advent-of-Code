import String

IO.stream()
|> Stream.map(&(&1
  |> String.split
  |> then(fn [h, t] -> [h, to_integer(t)] end)))
|> Stream.transform({0, 0, 0}, fn [dir, n], {x, y, a} ->
  case dir do
    "forward" ->
      {x,y,a} = {x+n,y+(n*a),a}
      {[x*y],{x,y,a}}
    "down" ->
      {x,y,a} = {x,y,a+n}
      {[x*y],{x,y,a}}
    "up" ->
      {x,y,a} = {x,y,a-n}
      {[x*y],{x,y,a}}
  end
end)
|> Stream.take(-1)
|> Enum.each(&IO.inspect&1)
