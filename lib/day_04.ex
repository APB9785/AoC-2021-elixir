defmodule Day04 do
  @moduledoc false

  @path Application.app_dir(:advent_2021, "priv/day_4_input.txt")

  def parse_input(path) do
    [callouts | board_rows] =
      path
      |> File.read!()
      |> String.split("\n", trim: true)

    callouts =
      callouts
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    boards =
      Enum.map(board_rows, fn row ->
        row
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)
      |> Enum.chunk_every(5)
      |> Enum.map(&make_board/1)

    {callouts, boards}
  end

  def part_1 do
    {callouts, boards} = parse_input(@path)
    {winning_board, called, final_call} = part_1_do(callouts, boards, MapSet.new())

    score_board(winning_board, called, final_call)
  end

  def part_1_do([h | t], boards, called) do
    called = MapSet.put(called, h)

    case Enum.find(boards, &check_bingo?(&1, called)) do
      nil -> part_1_do(t, boards, called)
      board -> {board, called, h}
    end
  end

  def part_2 do
    {callouts, boards} = parse_input(@path)
    {last_board, called, final_call} = part_2_do(callouts, boards, MapSet.new())

    score_board(last_board, called, final_call)
  end

  def part_2_do([h | t], boards, called) do
    called = MapSet.put(called, h)

    case Enum.reject(boards, &check_bingo?(&1, called)) do
      [] -> {hd(boards), called, h}
      losers -> part_2_do(t, losers, called)
    end
  end

  defp make_board([row_1, row_2, row_3, row_4, row_5] = full) do
    %{
      row_1: row_1,
      row_2: row_2,
      row_3: row_3,
      row_4: row_4,
      row_5: row_5,
      col_1: Enum.map(full, &Enum.at(&1, 0)),
      col_2: Enum.map(full, &Enum.at(&1, 1)),
      col_3: Enum.map(full, &Enum.at(&1, 2)),
      col_4: Enum.map(full, &Enum.at(&1, 3)),
      col_5: Enum.map(full, &Enum.at(&1, 4))
    }
  end

  defp check_bingo?(board, called) do
    Enum.any?(board, fn {_, nums} -> check_single?(nums, called) end)
  end

  defp check_single?(nums, called) do
    Enum.all?(nums, &MapSet.member?(called, &1))
  end

  defp score_board(%{row_1: r1, row_2: r2, row_3: r3, row_4: r4, row_5: r5}, called, final_call) do
    [r1, r2, r3, r4, r5]
    |> List.flatten()
    |> Enum.reject(&MapSet.member?(called, &1))
    |> Enum.sum()
    |> Kernel.*(final_call)
  end
end
