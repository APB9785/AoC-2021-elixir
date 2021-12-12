defmodule Day11 do
  @moduledoc false

  @path Application.app_dir(:advent_2021, "priv/day_11_input.txt")

  def parse_input do
    @path
    |> File.read!()
    |> String.graphemes()
    |> make_map()
  end

  defp make_map(todo, x \\ 0, y \\ 0, acc \\ %{})

  defp make_map([], _, _, acc), do: acc

  defp make_map(["\n" | t], _x, y, acc) do
    make_map(t, 0, y + 1, acc)
  end

  defp make_map([h | t], x, y, acc) do
    entry = {:ready, String.to_integer(h)}
    new_acc = Map.put(acc, {x, y}, entry)

    make_map(t, x + 1, y, new_acc)
  end

  def part_1 do
    init_map = parse_input()

    {_final_map, final_flash_count} =
      Enum.reduce(1..100, {init_map, 0}, fn _step, {acc, flash_count} ->
        after_step = run_step(acc)
        next_acc = Map.map(after_step, &reset_to_ready/1)

        {next_acc, flash_count + count_flashed(after_step)}
      end)

    final_flash_count
  end

  def part_2 do
    init_map = parse_input()

    Enum.reduce_while(1..9999, init_map, fn step, acc ->
      after_step = run_step(acc)

      if count_flashed(after_step) == 100 do
        {:halt, step}
      else
        {:cont, Map.map(after_step, &reset_to_ready/1)}
      end
    end)
  end

  defp run_step(map) do
    map
    |> increment_all()
    |> flashes()
  end

  defp increment_all(map) do
    Map.map(map, fn {_key, {status, energy}} ->
      {status, energy + 1}
    end)
  end

  defp flashes(map) do
    case Enum.filter(map, &going_to_flash?/1) do
      [] ->
        map

      to_flash ->
        to_flash
        |> Enum.reduce(map, fn {coord, _}, acc -> do_flash(acc, coord) end)
        |> flashes()
    end
  end

  defp going_to_flash?({_coord, {:flashed, _}}), do: false
  defp going_to_flash?({_coord, {_status, energy}}), do: energy > 9

  defp do_flash(map, coord) do
    coord
    |> neighbors()
    |> Enum.reduce(map, fn neighbor, acc ->
      case map[neighbor] do
        nil -> acc
        {:flashed, _} -> acc
        {status, energy} -> Map.put(acc, neighbor, {status, energy + 1})
      end
    end)
    |> Map.put(coord, {:flashed, 0})
  end

  defp neighbors({x, y}) do
    [
      {x + 1, y},
      {x + 1, y + 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x - 1, y + 1},
      {x - 1, y - 1},
      {x, y + 1},
      {x, y - 1}
    ]
  end

  defp reset_to_ready({_coord, {_status, energy}}), do: {:ready, energy}

  defp count_flashed(map) do
    Enum.count(map, fn {_coord, {status, _energy}} ->
      status == :flashed
    end)
  end

  # Just for debugging

  def print_map(map, x \\ 0, y \\ 0, acc \\ [])

  def print_map(_, 10, 9, acc), do: acc |> Enum.reverse() |> IO.puts()

  def print_map(map, 10, y, acc), do: print_map(map, 0, y + 1, ["\n" | acc])

  def print_map(map, x, y, acc) do
    {_status, energy} = map[{x, y}]
    print_map(map, x + 1, y, [Integer.to_string(energy) | acc])
  end
end
