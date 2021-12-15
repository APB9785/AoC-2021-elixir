defmodule Day14 do
  @moduledoc false

  defmodule State do
    @moduledoc false
    defstruct [:pairs, :letters, :rules]
  end

  @path Application.app_dir(:advent_2021, "priv/day_14_input.txt")

  def parse_input do
    [template, rules] =
      @path
      |> File.read!()
      |> String.split("\n\n")

    %State{
      pairs:
        template
        |> String.graphemes()
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.frequencies(),
      letters:
        template
        |> String.graphemes()
        |> Enum.frequencies(),
      rules:
        rules
        |> String.split("\n", trim: true)
        |> Enum.map(&parse_rule/1)
        |> Map.new()
    }
  end

  defp parse_rule(rule) do
    [pair, addition] = String.split(rule, " -> ")
    [a, b] = pair = String.graphemes(pair)

    {pair, {[a, addition], [addition, b]}}
  end

  def part_1 do
    parse_input() |> do_step(10)
  end

  def part_2 do
    parse_input() |> do_step(40)
  end

  def do_step(%State{letters: letters}, 0) do
    {{_, lo_score}, {_, hi_score}} = Enum.min_max_by(letters, &elem(&1, 1))

    hi_score - lo_score
  end

  def do_step(%State{pairs: pairs, rules: rules} = state, iterations) do
    pairs
    |> Enum.reduce(state, fn {pair, count}, acc ->
      {[_, c] = a, [c, _] = b} = Map.fetch!(rules, pair)

      acc
      |> decrement_pair(pair, count)
      |> update_new_pairs(a, b, count)
      |> add_letters(c, count)
    end)
    |> do_step(iterations - 1)
  end

  defp decrement_pair(state, pair, count) do
    Map.update!(state, :pairs, fn pairs ->
      Map.update!(pairs, pair, &(&1 - count))
    end)
  end

  defp update_new_pairs(state, a, b, count) do
    Map.update!(state, :pairs, fn pairs ->
      pairs
      |> Map.update(a, count, &(&1 + count))
      |> Map.update(b, count, &(&1 + count))
    end)
  end

  defp add_letters(state, c, count) do
    Map.update!(state, :letters, fn letters ->
      Map.update(letters, c, count, &(&1 + count))
    end)
  end
end
