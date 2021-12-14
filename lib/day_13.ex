defmodule Day13 do
  @moduledoc false

  @path Application.app_dir(:advent_2021, "priv/day_13_input.txt")

  def parse_input do
    [coords, folds] =
      @path
      |> File.read!()
      |> String.split("\n\n")

    parsed_coords =
      coords
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_coord/1)

    parsed_folds =
      folds
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_fold/1)

    {parsed_coords, parsed_folds}
  end

  defp parse_coord(coord) do
    coord
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp parse_fold(line) do
    ["fold", "along", data] = String.split(line, " ")
    [axis, n] = String.split(data, "=")

    {String.to_integer(n), String.to_atom(axis)}
  end

  def part_1 do
    {coords, folds} = parse_input()
    first_fold = hd(folds)

    coords
    |> Enum.map(&fold_coord(&1, first_fold))
    |> MapSet.new()
    |> MapSet.size()
  end

  def part_2 do
    {coords, folds} = parse_input()

    folds
    |> Enum.reduce(coords, fn fold, acc ->
      Enum.map(acc, &fold_coord(&1, fold))
    end)
    |> MapSet.new()
    |> display_coords()
  end

  def fold_coord({x, y}, {n, axis}) do
    case axis do
      :x -> if x < n, do: {x, y}, else: {2 * n - x, y}
      :y -> if y < n, do: {x, y}, else: {x, 2 * n - y}
    end
  end

  def display_coords(coords) do
    bounds =
      coords
      |> MapSet.to_list()
      |> get_bounds()

    {{lo_x, lo_y}, _hi} = bounds

    do_display(lo_x, lo_y, coords, bounds, [])
  end

  def do_display(_x, y, _coords, {_lo, {_, hi_y}}, acc) when y > hi_y do
    acc
    |> Enum.reverse()
    |> Enum.join()
    |> IO.puts()
  end

  def do_display(x, y, coords, {{lo_x, _}, {hi_x, _}} = bounds, acc) when x > hi_x do
    do_display(lo_x, y + 1, coords, bounds, ["\n" | acc])
  end

  def do_display(x, y, coords, bounds, acc) do
    char = if MapSet.member?(coords, {x, y}), do: "█", else: " "

    do_display(x + 1, y, coords, bounds, [char | acc])
  end

  defp get_bounds(coords, lo \\ {999, 999}, hi \\ {-999, -999})

  defp get_bounds([], lo, hi), do: {lo, hi}

  defp get_bounds([{x, y} | t], {lo_x, lo_y}, {hi_x, hi_y}) do
    lowest_x = Enum.min([x, lo_x])
    lowest_y = Enum.min([y, lo_y])
    highest_x = Enum.max([x, hi_x])
    highest_y = Enum.max([y, hi_y])

    get_bounds(t, {lowest_x, lowest_y}, {highest_x, highest_y})
  end
end
