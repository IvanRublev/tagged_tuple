defmodule TaggedTupleTest do
  use ExUnit.Case, async: true

  doctest TaggedTuple

  test "provides tagged tuple --- operator and helper functions" do
    use TaggedTuple

    autumn = :temperature --- :celcius --- 15
    assert autumn === {:temperature, {:celcius, 15}}

    assert :temperature --- measure --- value = autumn
    assert measure == :celcius
    assert value == 15

    assert TaggedTuple.tag(15, :temperature --- :celcius) == autumn
    assert TaggedTuple.untag!(autumn, :temperature) == :celcius --- 15
    assert TaggedTuple.untag!(autumn, :temperature --- :celcius) == 15

    assert TaggedTuple.tag(15, []) == 15
    assert TaggedTuple.tag(15, [:celcius]) == :celcius --- 15
    assert TaggedTuple.tag(15, [:temperature, :celcius]) == autumn
    assert TaggedTuple.untag!(autumn, [:temperature]) == :celcius --- 15
    assert TaggedTuple.untag!(autumn, [:temperature, :celcius]) == 15

    assert TaggedTuple.split(:celcius --- 15) == :celcius --- 15

    assert TaggedTuple.split(:measurement --- :temperature --- :celcius --- 15) ==
             {:measurement --- :temperature --- :celcius, 15}

    assert TaggedTuple.to_list(:temperature) == [:temperature]
    assert TaggedTuple.to_list(:temperature --- :celcius --- 15) == [:temperature, :celcius, 15]

    assert TaggedTuple.to_list(:temperature --- :celcius --- 15, & &1, &(&1 * 100)) == [
             :temperature,
             :celcius,
             1500
           ]

    assert TaggedTuple.to_list(:temperature --- :celcius --- 15, &to_string/1, &(&1 * 10)) == [
             "temperature",
             "celcius",
             150
           ]

    assert TaggedTuple.from_list([:temperature]) == :temperature

    assert TaggedTuple.from_list([:temperature, :celcius, 1500]) ==
             :temperature --- :celcius --- 1500

    assert TaggedTuple.from_list([:temperature, :celcius, 1500], & &1, &div(&1, 100)) ==
             :temperature --- :celcius --- 15

    assert TaggedTuple.from_list(
             ["temperature", "celcius", 1500],
             &String.to_existing_atom/1,
             &div(&1, 10)
           ) == :temperature --- :celcius --- 150

    assert TaggedTuple.to_map(:temperature --- :celcius --- 15) == %{temperature: %{celcius: 15}}

    assert TaggedTuple.to_map(:temperature --- :celcius --- 15, & &1, &(&1 * 100)) == %{
             temperature: %{celcius: 1500}
           }

    assert TaggedTuple.to_map(:temperature --- :celcius --- 15, &to_string/1, &(&1 * 10)) == %{
             "temperature" => %{"celcius" => 150}
           }

    assert TaggedTuple.from_map(%{temperature: %{celcius: 15}}) ==
             :temperature --- :celcius --- 15

    assert TaggedTuple.from_map(%{temperature: %{celcius: 1500}}, & &1, &div(&1, 100)) ==
             :temperature --- :celcius --- 15

    assert TaggedTuple.from_map(
             %{"temperature" => %{"celcius" => 150}},
             &String.to_existing_atom/1,
             &div(&1, 10)
           ) ==
             :temperature --- :celcius --- 15
  end
end
