defmodule Day16AST do
  @moduledoc """
  Alternate solution for Day 16 using Elixir AST instead of %Packet{}
  """

  @path Application.app_dir(:advent_2021, "priv/day_16_input.txt")

  def solve do
    {ast, _} =
      @path
      |> File.read!()
      |> String.trim_trailing()
      |> Base.decode16!()
      |> make_ast()

    Code.eval_quoted(ast)
  end

  defp make_ast(<<_version::3, 4::3, rest::bitstring>>) do
    {value, rest} = parse_literal(rest)
    pad_length = 8 - rem(bit_size(value), 8)
    ast = :binary.decode_unsigned(<<0::size(pad_length), value::bitstring>>)

    {ast, rest}
  end

  defp make_ast(<<_version::3, type_id::3, 0::1, len::15, rest::bitstring>>) do
    <<values::bitstring-size(len), rest::bitstring>> = rest

    ast =
      case type_id do
        0 -> values |> parse_values() |> ast_reduce(0, :+)
        1 -> values |> parse_values() |> ast_reduce(1, :*)
        2 -> values |> parse_values() |> ast_reduce(:infinity, :min)
        3 -> values |> parse_values() |> ast_reduce(0, :max)
        5 -> values |> parse_values() |> ast_if(:>)
        6 -> values |> parse_values() |> ast_if(:<)
        7 -> values |> parse_values() |> ast_if(:==)
      end

    {ast, rest}
  end

  defp make_ast(<<_version::3, type_id::3, 1::1, qty::11, rest::bitstring>>) do
    {values, rest} =
      Enum.reduce(1..qty, {[], rest}, fn _, {acc, rest} ->
        {packet, rest} = make_ast(rest)
        {[packet | acc], rest}
      end)

    values = Enum.reverse(values)

    ast =
      case type_id do
        0 -> ast_reduce(values, 0, :+)
        1 -> ast_reduce(values, 1, :*)
        2 -> ast_reduce(values, :infinity, :min)
        3 -> ast_reduce(values, 0, :max)
        5 -> ast_if(values, :>)
        6 -> ast_if(values, :<)
        7 -> ast_if(values, :==)
      end

    {ast, rest}
  end

  defp parse_literal(value_bin, acc \\ <<>>)

  defp parse_literal(<<1::1, group::bitstring-size(4), rest::bitstring>>, acc) do
    parse_literal(rest, <<acc::bitstring, group::bitstring>>)
  end

  defp parse_literal(<<0::1, group::bitstring-size(4), rest::bitstring>>, acc) do
    {<<acc::bitstring, group::bitstring>>, rest}
  end

  defp parse_values(values_bin, acc \\ [])

  defp parse_values("", acc), do: Enum.reverse(acc)

  defp parse_values(values_bin, acc) do
    {ast, rest} = make_ast(values_bin)

    parse_values(rest, [ast | acc])
  end

  defp ast_reduce(parsed_values, init_acc, op) do
    {{:., [], [{:__aliases__, [alias: false], [:Enum]}, :reduce]}, [],
     [
       parsed_values,
       init_acc,
       {:&, [import: Kernel, context: Elixir],
        [
          {:/, [context: Elixir, import: Kernel], [{op, [if_undefined: :apply], Elixir}, 2]}
        ]}
     ]}
  end

  defp ast_if(parsed_values, op) do
    {:if, [context: Elixir, import: Kernel],
     [{op, [context: Elixir, import: Kernel], parsed_values}, [do: 1, else: 0]]}
  end
end
