defmodule Day07 do
  @moduledoc false

  @path Application.app_dir(:advent_2021, "priv/day_7_input.txt")

  def parse_input(path) do
    path
    |> File.read!()
    |> String.trim_trailing()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def part_1 do
    subs = parse_input(@path)
    best_alignment_position(subs, :part_1)
  end

  def part_2 do
    subs = parse_input(@path)
    best_alignment_position(subs, :part_2)
  end

  defp best_alignment_position(subs, part) do
    {min, max} = Enum.min_max(subs)

    min..max
    |> Stream.map(&fuel_needed(&1, subs, part))
    |> Enum.min()
  end

  defp fuel_needed(alignment_position, subs, :part_1) do
    Enum.reduce(subs, 0, fn sub_position, fuel_count ->
      fuel_count + abs(sub_position - alignment_position)
    end)
  end

  defp fuel_needed(alignment_position, subs, :part_2) do
    Enum.reduce(subs, 0, fn sub_position, fuel_count ->
      distance = abs(sub_position - alignment_position)
      fuel_count + series(distance)
    end)
  end

  defp series(n), do: div(n * (n + 1), 2)
end
