# Streams the file, never loads it to memory

defmodule Filter do
  @enforce_keys [:idx, :valid_char]
  defstruct [:idx, :valid_char]
  def create(idx, char) do
    %__MODULE__{
      idx: idx,
      valid_char: char
    }
  end
end

defmodule A do
  @type rating :: :oxygen | :co2
  @type count :: {integer, String.t}
  @type result :: {count, count}

  def stream_device(device, filters) do
    :file.position(device, 0)

    IO.stream(device, :line)
    |> Stream.map(&String.trim&1)
    |> Stream.filter(fn string ->
      passes_filters(string, filters)
    end)
  end

  def passes_filters(string, filters) do
      Enum.reduce_while(filters, true,
        fn filter, _acc ->
          %Filter{idx: i, valid_char: vc}
            = filter
          char = String.at(string, i)
          cond do
            vc == char -> {:cont, true}
            true -> {:halt, false}
          end
        end)
  end

  @spec ones_and_zeroes(any, any, any) :: result
  def ones_and_zeroes(device, string_index, filters) do
    stream_device(device, filters)
      |> Stream.map(&{String.at(&1, string_index),&1})
      |> Enum.reduce({{0, nil},{0, nil}}, fn
        {bit, string}, {ones, zeroes} ->
          case bit do
            "0" ->
              { total, _last } = zeroes
              {ones, {total + 1, string}}
            "1" ->
              { total, _last } = ones
              {{total + 1, string}, zeroes}
          end
        end)
  end

  @spec found_answer?(result, rating)
  :: ({boolean, String.t} | {boolean})
  def found_answer?(result, rating) do
    {
      {ones_total, ones_l},
      {zeroes_total, zeroes_l}
    } = result
    cond do
      ones_total == 1 && zeroes_total == 1 ->
        case rating do
          :oxygen -> {true, ones_l}
          :co2 -> {true, zeroes_l}
        end
      true -> {false}
    end
  end

  def process(device, rating, idx \\ 0, filters \\ []) do
    result = ones_and_zeroes(device, idx, filters)
    finished? = found_answer?(result, rating)
    case finished? do
      {true, answer} ->
        IO.inspect(answer)
      {false} ->
        char = valid_char(result, rating)
        new_filter = Filter.create(idx, char)
        filters_p = [new_filter | filters]
        process(device, rating, idx+1, filters_p)
    end
  end

  @spec valid_char(result, rating) :: String.t
  def valid_char(tuple, rating) do
    {{ones, _}, {zeroes, _}} = tuple
    [compare, preference] =
      case rating do
        :oxygen -> [& &1>&2, "1"]
        :co2 -> [& &1 < &2, "0"]
      end
    cond do
      compare.(ones, zeroes) -> "1"
      compare.(zeroes, ones) -> "0"
      # equal number of zeroes and ones
      true  -> preference
    end
  end

end

file_name = "input"
{:ok, file} = File.open(file_name, [:read, :binary])
device = file
oxygen = A.process(device, :oxygen, 0)
|> Integer.parse(2) |> elem(0)
co2 = A.process(device, :co2, 0)
|> Integer.parse(2) |> elem(0)
IO.puts("Answer: #{oxygen * co2}")

# elixir b.exs
