defmodule Day02 do
  @moduledoc false

  @path Application.app_dir(:advent_2021, "priv/day_2_input.txt")

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
  end

  def part_1 do
    commands = parse_input(@path)

    {x, y} =
      Enum.reduce(commands, {0, 0}, fn [direction, steps], {horizontal, depth} ->
        steps = String.to_integer(steps)

        case direction do
          "forward" -> {horizontal + steps, depth}
          "down" -> {horizontal, depth + steps}
          "up" -> {horizontal, depth - steps}
        end
      end)

    x * y
  end

  def part_2 do
    commands = parse_input(@path)

    {x, y, _} =
      Enum.reduce(commands, {0, 0, 0}, fn [direction, steps], {horizontal, depth, aim} ->
        steps = String.to_integer(steps)

        case direction do
          "forward" -> {horizontal + steps, depth + aim * steps, aim}
          "down" -> {horizontal, depth, aim + steps}
          "up" -> {horizontal, depth, aim - steps}
        end
      end)

    x * y
  end
end
