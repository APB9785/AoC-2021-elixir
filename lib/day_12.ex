defmodule Day12 do
  @moduledoc false

  defmodule State do
    defstruct [:seen, :current]
  end

  @path Application.app_dir(:advent_2021, "priv/day_12_input.txt")

  def parse_input do
    @path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&tuples_with_size/1)
    |> map_pairs()
  end

  defp tuples_with_size(line) do
    line
    |> String.split("-")
    |> Enum.map(&{&1, cave_size(&1)})
    |> List.to_tuple()
  end

  defp map_pairs(pairs) do
    Enum.reduce(pairs, %{}, fn {a, b}, acc ->
      acc
      |> Map.update(a, [b], &[b | &1])
      |> Map.update(b, [a], &[a | &1])
    end)
  end

  defp cave_size(<<first::binary-1, _::binary>>) do
    case String.downcase(first) do
      ^first -> :small
      _first -> :big
    end
  end

  def part_1 do
    caves_map = parse_input()
    init_states = [%State{current: {"start", :small}, seen: MapSet.new(["start"])}]

    travel_caves(init_states, caves_map)
  end

  defp travel_caves(states, map, path_count \\ 0)

  defp travel_caves([], _, path_count), do: path_count

  defp travel_caves(states, map, path_count) do
    next_states =
      Enum.reduce(states, [], fn %State{current: current} = state, acc ->
        map
        |> Map.fetch!(current)
        |> valid_neighbor_states(state)
        |> Kernel.++(acc)
      end)

    {unfinished_states, finished_count} = process_states(next_states)

    travel_caves(unfinished_states, map, path_count + finished_count)
  end

  defp valid_neighbor_states(neighbors, state) do
    Enum.reduce(neighbors, [], fn neighbor, acc ->
      case make_new_state(neighbor, state) do
        nil -> acc
        new_state -> [new_state | acc]
      end
    end)
  end

  defp make_new_state({name, size} = next, root) do
    cond do
      size == :big ->
        Map.put(root, :current, next)

      MapSet.member?(root.seen, name) ->
        # Already been to this room
        nil

      :otherwise ->
        root
        |> Map.put(:current, next)
        |> Map.update!(:seen, &MapSet.put(&1, name))
    end
  end

  defp process_states(states) do
    {finished, unfinished} =
      Enum.split_with(states, fn %State{current: {name, _size}} ->
        name == "end"
      end)

    {unfinished, Enum.count(finished)}
  end
end
