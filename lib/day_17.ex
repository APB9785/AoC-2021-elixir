defmodule Day17 do
  @moduledoc false

  defmodule Target do
    @moduledoc """
    The target box to hit.
    """
    defstruct [:x_range, :y_range]
  end

  @path Application.app_dir(:advent_2021, "priv/day_17_input.txt")

  def parse_input do
    input = File.read!(@path)
    reg_exp = ~r/target area: x=(-?\d*)..(-?\d*), y=(-?\d*)..(-?\d*)/

    res =
      reg_exp
      |> Regex.run(input)
      |> tl()

    [x1, x2, y1, y2] = Enum.map(res, &String.to_integer/1)

    %Target{x_range: x1..x2, y_range: y1..y2}
  end

  def part_1 do
    target = parse_input()
    y1 = target.y_range.first

    div(y1 * (y1 + 1), 2)
  end

  def part_2 do
    target = parse_input()

    vels =
      for x <- 0..target.x_range.last,
          y <- target.y_range.first..-target.y_range.first do
        {x, y}
      end

    Enum.count(vels, &valid?(&1, target))
  end

  def valid?(vel, target, coord \\ {0, 0})

  def valid?({x_vel, y_vel} = vel, target, {x, y} = coord) do
    cond do
      x > target.x_range.last -> false
      y < target.y_range.first -> false
      in_target?(coord, target) -> true
      :otherwise -> vel |> drag() |> valid?(target, {x + x_vel, y + y_vel})
    end
  end

  def in_target?({x, y}, %Target{x_range: xr, y_range: yr}) do
    x >= xr.first and x <= xr.last and y >= yr.first and y <= yr.last
  end

  def drag({x, y}) do
    x = if x == 0, do: 0, else: x - 1
    y = y - 1

    {x, y}
  end
end
