defmodule Day10 do
  @moduledoc false

  @path Application.app_dir(:advent_2021, "priv/day_10_input.txt")
  @openers ["(", "{", "[", "<"]
  @matches %{"(" => ")", "{" => "}", "[" => "]", "<" => ">"}

  def parse_input do
    @path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Stream.map(&String.graphemes/1)
    |> Stream.map(&process_line/1)
  end

  defp process_line(line, needed \\ [])

  defp process_line([], needed), do: {:incomplete, needed}

  defp process_line([todo | rest], needed) when todo in @openers do
    process_line(rest, [@matches[todo] | needed])
  end

  defp process_line([todo | rest], [match | others]) when todo == match do
    process_line(rest, others)
  end

  defp process_line([todo | _], _), do: {:corrupted, todo}

  def part_1 do
    parse_input()
    |> Stream.reject(&(elem(&1, 0) == :incomplete))
    |> Enum.reduce(0, fn {:corrupted, char}, score ->
      score + score_char_p1(char)
    end)
  end

  defp score_char_p1(")"), do: 3
  defp score_char_p1("]"), do: 57
  defp score_char_p1("}"), do: 1197
  defp score_char_p1(">"), do: 25137

  def part_2 do
    scores =
      parse_input()
      |> Stream.reject(&(elem(&1, 0) == :corrupted))
      |> Stream.map(fn {:incomplete, needed} -> score_needed(needed) end)
      |> Enum.sort()

    middle_index = scores |> length() |> div(2)

    Enum.at(scores, middle_index)
  end

  defp score_needed(needed) do
    Enum.reduce(needed, 0, fn char, score ->
      score * 5 + score_char_p2(char)
    end)
  end

  defp score_char_p2(")"), do: 1
  defp score_char_p2("]"), do: 2
  defp score_char_p2("}"), do: 3
  defp score_char_p2(">"), do: 4
end
