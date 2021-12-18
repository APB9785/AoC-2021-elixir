defmodule Day16 do
  @moduledoc """
  Original solution using %Packet{} struct.
  """

  defmodule Packet do
    defstruct [:version, :type_id, :value]
  end

  @path Application.app_dir(:advent_2021, "priv/day_16_input.txt")

  def parse_input do
    @path
    |> File.read!()
    |> String.trim_trailing()
    |> Base.decode16!()
  end

  def part_1 do
    parse_input()
    |> parse()
    |> elem(0)
    |> score()
  end

  def part_2 do
    parse_input()
    |> parse()
    |> elem(0)
    |> eval()
  end

  def parse(<<version::3, 4::3, rest::bitstring>>) do
    {value, rest} = parse_literal(rest)

    packet = %Packet{
      version: version,
      type_id: 4,
      value: value
    }

    {packet, rest}
  end

  def parse(
        <<version::3, type_id::3, 0::1, len::15, values::bitstring-size(len), rest::bitstring>>
      ) do
    packet = %Packet{
      version: version,
      type_id: type_id,
      value: parse_values(values)
    }

    {packet, rest}
  end

  def parse(<<version::3, type_id::3, 1::1, qty::11, rest::bitstring>>) do
    {values, rest} =
      Enum.reduce(1..qty, {[], rest}, fn _, {acc, rest} ->
        {packet, rest} = parse(rest)
        {[packet | acc], rest}
      end)

    packet = %Packet{
      version: version,
      type_id: type_id,
      value: Enum.reverse(values)
    }

    {packet, rest}
  end

  def parse_literal(value_bin, acc \\ <<>>)

  def parse_literal(<<1::1, group::bitstring-size(4), rest::bitstring>>, acc) do
    parse_literal(rest, <<acc::bitstring, group::bitstring>>)
  end

  def parse_literal(<<0::1, group::bitstring-size(4), rest::bitstring>>, acc) do
    {<<acc::bitstring, group::bitstring>>, rest}
  end

  def parse_values(values_bin, acc \\ [])

  def parse_values("", acc), do: Enum.reverse(acc)

  def parse_values(values_bin, acc) do
    {packet, rest} = parse(values_bin)

    parse_values(rest, [packet | acc])
  end

  def score(%Packet{type_id: 4, version: version}) do
    version
  end

  def score(%Packet{version: version, value: values}) do
    Enum.reduce(values, version, fn packet, acc ->
      acc + score(packet)
    end)
  end

  def eval(%Packet{type_id: type, value: value}) do
    case type do
      0 ->
        Enum.reduce(value, 0, fn packet, acc ->
          acc + eval(packet)
        end)

      1 ->
        Enum.reduce(value, 1, fn packet, acc ->
          acc * eval(packet)
        end)

      2 ->
        Enum.reduce(value, :infinity, fn packet, acc ->
          packet
          |> eval()
          |> min(acc)
        end)

      3 ->
        Enum.reduce(value, 0, fn packet, acc ->
          packet
          |> eval()
          |> max(acc)
        end)

      4 ->
        pad_length = 8 - rem(bit_size(value), 8)

        <<0::size(pad_length), value::bitstring>>
        |> :binary.decode_unsigned()

      5 ->
        [a, b] = value |> Enum.map(&eval/1)
        if a > b, do: 1, else: 0

      6 ->
        [a, b] = value |> Enum.map(&eval/1)
        if a < b, do: 1, else: 0

      7 ->
        [a, b] = value |> Enum.map(&eval/1)
        if a == b, do: 1, else: 0
    end
  end
end
