IO.stream()
|> Stream.map(&String.split(String.trim(&1), "", trim: true))
|> Stream.transform([], fn binlist, total ->
  intlist =
    for n <- binlist do
      case n do
      "0" -> -1
      "1" -> 1
      end
    end
  # updates total based on current input
  [latot | _] =
    for n <- intlist, reduce: [[], total] do
      [result, []] ->
        result = [n | result]
        [result, []]
      [result, total] ->
        [head | newTotal] = total
        result = [n + head | result]
        [result, newTotal]
    end
  total = Enum.reverse latot
  [gamma, epsilon] =
    for n <- total do
      cond do
        n > 0 -> [1,0]
        true -> [0,1]
      end
    end
  |> List.zip
  |> Enum.map(&Enum.join Tuple.to_list&1)

  power = for n <- [gamma, epsilon]
    do
      n |> Integer.parse(2) |> elem(0)
    end
    |> Enum.take(2) |> Enum.product
  return = [gamma: gamma, epsilon: epsilon, power: power]
  {[return], total}
end)
|> Stream.take(-1)
|> Enum.map(&IO.inspect&1)
