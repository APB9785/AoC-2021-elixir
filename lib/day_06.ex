defmodule Day06 do
  @moduledoc false

  @path Application.app_dir(:advent_2021, "priv/day_6_input.txt")

  def parse_input(path) do
    path
    |> File.read!()
    |> String.trim_trailing()
    |> String.split(",")
    |> Enum.frequencies()
    |> Enum.map(fn {k, v} -> {String.to_integer(k), v} end)
  end

  def part_1 do
    fish = parse_input(@path)
    run_simulation(fish, 80)
  end

  def part_2 do
    fish = parse_input(@path)
    run_simulation(fish, 256)
  end

  def run_simulation(fish, max_reps, reps \\ 1)

  def run_simulation(fish, max_reps, reps) when reps > max_reps do
    Enum.reduce(fish, 0, fn {_, count}, acc -> acc + count end)
  end

  def run_simulation(fish, max_reps, reps) do
    fish
    |> Enum.reduce(%{}, fn {timer, count}, acc ->
      if timer > 0 do
        tally_fish(acc, timer - 1, count)
      else
        acc
        |> tally_fish(6, count)
        |> tally_fish(8, count)
      end
    end)
    |> run_simulation(max_reps, reps + 1)
  end

  defp tally_fish(fish, timer, count) do
    Map.update(fish, timer, count, &(&1 + count))
  end
end
