defmodule Day05 do
  @moduledoc false

  @path Application.app_dir(:advent_2021, "priv/day_5_input.txt")
  @orthogonal [:north, :south, :east, :west]

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Stream.map(&parse_line/1)
    |> Enum.map(&List.to_tuple/1)
  end

  def parse_line(line) do
    line
    |> String.split(" -> ")
    |> Enum.map(&parse_coord/1)
  end

  def parse_coord(coord) do
    coord
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def part_1 do
    @path
    |> parse_input()
    |> Enum.filter(fn line -> line_direction(line) in @orthogonal end)
    |> plot_lines_to_map()
    |> Enum.count(fn {_k, v} -> v > 1 end)
  end

  def part_2 do
    @path
    |> parse_input()
    |> plot_lines_to_map()
    |> Enum.count(fn {_k, v} -> v > 1 end)
  end

  def plot_lines_to_map(lines) do
    Enum.reduce(lines, %{}, fn line, acc ->
      line
      |> line_to_points()
      |> add_points_to_map(acc)
    end)
  end

  def line_to_points({initial, final} = line) do
    line
    |> line_direction()
    |> travel(initial, final)
  end

  def line_direction({{x1, y1}, {x2, y2}}) do
    cond do
      x1 < x2 ->
        cond do
          y1 > y2 -> :northeast
          y1 < y2 -> :southeast
          y1 == y2 -> :east
        end

      x1 > x2 ->
        cond do
          y1 > y2 -> :northwest
          y1 < y2 -> :southwest
          y1 == y2 -> :west
        end

      y1 > y2 ->
        :north

      y1 < y2 ->
        :south
    end
  end

  def travel(direction, coord, final, points \\ [])

  def travel(_, coord, final, points) when coord == final, do: [coord | points]

  def travel(direction, {x, y} = coord, final, points) do
    case direction do
      :north -> travel(direction, {x, y - 1}, final, [coord | points])
      :south -> travel(direction, {x, y + 1}, final, [coord | points])
      :east -> travel(direction, {x + 1, y}, final, [coord | points])
      :west -> travel(direction, {x - 1, y}, final, [coord | points])
      :southeast -> travel(direction, {x + 1, y + 1}, final, [coord | points])
      :southwest -> travel(direction, {x - 1, y + 1}, final, [coord | points])
      :northeast -> travel(direction, {x + 1, y - 1}, final, [coord | points])
      :northwest -> travel(direction, {x - 1, y - 1}, final, [coord | points])
    end
  end

  def add_points_to_map(points, map) do
    Enum.reduce(points, map, fn point, acc ->
      Map.update(acc, point, 1, &(&1 + 1))
    end)
  end
end
