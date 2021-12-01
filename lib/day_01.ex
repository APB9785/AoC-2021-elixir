defmodule Day01 do
  @moduledoc false

  @path Application.app_dir(:advent_2021, "priv/day_1_input.txt")

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def part_1 do
    [h | t] = parse_input(@path)

    {_, final_count} =
      Enum.reduce(t, {h, 0}, fn number, {last, count} ->
        if number > last do
          {number, count + 1}
        else
          {number, count}
        end
      end)

    final_count
  end

  def part_2 do
    [a, b, c | rest] = parse_input(@path)

    do_p2([b, c | rest], a + b + c, 0)
  end

  def do_p2([a, b, c], current, increases) do
    if a + b + c > current do
      increases + 1
    else
      increases
    end
  end

  def do_p2([a, b, c | rest], current, increases) do
    s = a + b + c
    increases = if s > current, do: increases + 1, else: increases

    do_p2([b, c | rest], s, increases)
  end
end
