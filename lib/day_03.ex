defmodule Day03 do
  @moduledoc false

  @path Application.app_dir(:advent_2021, "priv/day_3_input.txt")
  @default_map Enum.reduce(0..11, %{}, &Map.put(&2, &1, 0))

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  def part_1 do
    input = parse_input(@path)
    min = length(input) / 2
    res = Enum.reduce(input, @default_map, &count_ones_per_index/2)

    gamma = process_result(res, min, {"1", "0"})
    epsilon = process_result(res, min, {"0", "1"})

    gamma * epsilon
  end

  defp process_result(result, min, {a, b}) do
    result
    |> Enum.map_join(fn {_, count} -> if count >= min, do: a, else: b end)
    |> String.to_integer(2)
  end

  def part_2 do
    tuples = parse_input(@path)

    oxygen = part_2_do(tuples, {0, 1})
    co2 = part_2_do(tuples, {1, 0})

    oxygen * co2
  end

  def part_2_do(tuples, bits, iter \\ 0)

  def part_2_do([last_tuple], _, _), do: format_last(last_tuple)

  def part_2_do(tuples, {a, b} = bits, iter) do
    res = Enum.reduce(tuples, @default_map, &count_ones_per_index/2)
    min = length(tuples) / 2
    target = if res[iter] >= min, do: a, else: b

    filtered = Enum.filter(tuples, &(target == elem(&1, iter)))

    part_2_do(filtered, bits, iter + 1)
  end

  defp count_ones_per_index(tuple, counts) do
    Enum.reduce(0..11, counts, fn idx, acc ->
      Map.update!(acc, idx, &(&1 + elem(tuple, idx)))
    end)
  end

  defp format_last(tuple) do
    tuple
    |> Tuple.to_list()
    |> Enum.map_join(&Integer.to_string/1)
    |> String.to_integer(2)
  end
end
