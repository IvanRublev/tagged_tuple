defmodule TagUntagTest do
  use ExUnit.Case, async: true

  describe "tag function" do
    test "returns tagged tuple by joining tag chain with a value" do
      assert TaggedTuple.tag(2.5, :t1) == {:t1, 2.5}
      assert TaggedTuple.tag(2.5, {:t2, :t1}) == {:t2, {:t1, 2.5}}
      assert TaggedTuple.tag(2.5, {:t3, {:t2, :t1}}) == {:t3, {:t2, {:t1, 2.5}}}
      assert TaggedTuple.tag(2.5, {:t4, {:t3, {:t2, :t1}}}) == {:t4, {:t3, {:t2, {:t1, 2.5}}}}

      assert TaggedTuple.tag(2.5, {:t5, {:t4, {:t3, {:t2, :t1}}}}) ==
               {:t5, {:t4, {:t3, {:t2, {:t1, 2.5}}}}}

      assert TaggedTuple.tag(2.5, {:t6, {:t5, {:t4, {:t3, {:t2, :t1}}}}}) ==
               {:t6, {:t5, {:t4, {:t3, {:t2, {:t1, 2.5}}}}}}
    end

    test "accepts tag chain as a list" do
      assert TaggedTuple.tag(2.5, [:t1]) == {:t1, 2.5}
      assert TaggedTuple.tag(2.5, [:t2, :t1]) == {:t2, {:t1, 2.5}}
      assert TaggedTuple.tag(2.5, [:t3, :t2, :t1]) == {:t3, {:t2, {:t1, 2.5}}}
      assert TaggedTuple.tag(2.5, [:t4, :t3, :t2, :t1]) == {:t4, {:t3, {:t2, {:t1, 2.5}}}}

      assert TaggedTuple.tag(2.5, [:t5, :t4, :t3, :t2, :t1]) ==
               {:t5, {:t4, {:t3, {:t2, {:t1, 2.5}}}}}

      assert TaggedTuple.tag(2.5, [:t6, :t5, :t4, :t3, :t2, :t1]) ==
               {:t6, {:t5, {:t4, {:t3, {:t2, {:t1, 2.5}}}}}}
    end
  end

  describe "untag! function" do
    test "returns core value from tagged tuple with matching tag chain" do
      assert TaggedTuple.untag!({:t1, 2.5}, :t1) == 2.5
      assert TaggedTuple.untag!({:t2, {:t1, 2.5}}, {:t2, :t1}) == 2.5
      assert TaggedTuple.untag!({:t3, {:t2, {:t1, 2.5}}}, {:t3, {:t2, :t1}}) == 2.5
      assert TaggedTuple.untag!({:t4, {:t3, {:t2, {:t1, 2.5}}}}, {:t4, {:t3, {:t2, :t1}}}) == 2.5

      assert TaggedTuple.untag!(
               {:t5, {:t4, {:t3, {:t2, {:t1, 2.5}}}}},
               {:t5, {:t4, {:t3, {:t2, :t1}}}}
             ) == 2.5

      assert TaggedTuple.untag!(
               {:t6, {:t5, {:t4, {:t3, {:t2, {:t1, 2.5}}}}}},
               {:t6, {:t5, {:t4, {:t3, {:t2, :t1}}}}}
             ) == 2.5
    end

    test "raises ArgumentError if tag chain does not match the tagged tuple" do
      assert_raise ArgumentError,
                   """
                   Tag chain {:foo, :bar} doesn't match one in the tagged tuple \
                   {:t2, {:t1, 2.5}}.\
                   """,
                   fn ->
                     TaggedTuple.untag!({:t2, {:t1, 2.5}}, {:foo, :bar})
                   end
    end

    test "accepts tag chain as a list" do
      assert TaggedTuple.untag!({:t1, 2.5}, [:t1]) == 2.5
      assert TaggedTuple.untag!({:t2, {:t1, 2.5}}, [:t2, :t1]) == 2.5
      assert TaggedTuple.untag!({:t3, {:t2, {:t1, 2.5}}}, [:t3, :t2, :t1]) == 2.5
      assert TaggedTuple.untag!({:t4, {:t3, {:t2, {:t1, 2.5}}}}, [:t4, :t3, :t2, :t1]) == 2.5

      assert TaggedTuple.untag!(
               {:t5, {:t4, {:t3, {:t2, {:t1, 2.5}}}}},
               [:t5, :t4, :t3, :t2, :t1]
             ) == 2.5

      assert TaggedTuple.untag!(
               {:t6, {:t5, {:t4, {:t3, {:t2, {:t1, 2.5}}}}}},
               [:t6, :t5, :t4, :t3, :t2, :t1]
             ) == 2.5
    end

    test "raises ArgumentError if tag chain given as list does not match the tagged tuple" do
      assert_raise ArgumentError,
                   """
                   Tag chain [:foo, :bar] doesn't match one in the tagged tuple \
                   {:t2, {:t1, 2.5}}.\
                   """,
                   fn ->
                     TaggedTuple.untag!({:t2, {:t1, 2.5}}, [:foo, :bar])
                   end
    end
  end

  describe "untag function" do
    test "returns ok reply with core value from tagged tuple with matching tag chain" do
      assert TaggedTuple.untag({:t1, 2.5}, :t1) == {:ok, 2.5}
      assert TaggedTuple.untag({:t2, {:t1, 2.5}}, {:t2, :t1}) == {:ok, 2.5}
      assert TaggedTuple.untag({:t3, {:t2, {:t1, 2.5}}}, {:t3, {:t2, :t1}}) == {:ok, 2.5}

      assert TaggedTuple.untag({:t4, {:t3, {:t2, {:t1, 2.5}}}}, {:t4, {:t3, {:t2, :t1}}}) ==
               {:ok, 2.5}

      assert TaggedTuple.untag(
               {:t5, {:t4, {:t3, {:t2, {:t1, 2.5}}}}},
               {:t5, {:t4, {:t3, {:t2, :t1}}}}
             ) == {:ok, 2.5}

      assert TaggedTuple.untag(
               {:t6, {:t5, {:t4, {:t3, {:t2, {:t1, 2.5}}}}}},
               {:t6, {:t5, {:t4, {:t3, {:t2, :t1}}}}}
             ) == {:ok, 2.5}
    end

    test "returns {:error, :mismatch} for tagged tuple with Non matching tag chain" do
      assert TaggedTuple.untag({:t2, {:t1, 2.5}}, {:foo, :bar}) == {:error, :mismatch}

      assert TaggedTuple.untag({:t3, {:t2, {:t1, 2.5}}}, {:t3, {:foo, :t1}}) ==
               {:error, :mismatch}

      assert TaggedTuple.untag({:t4, {:t3, {:t2, {:t1, 2.5}}}}, {:t4, {:t3, {:t2, :foo}}}) ==
               {:error, :mismatch}

      assert TaggedTuple.untag(
               {:t5, {:t4, {:t3, {:t2, {:t1, 2.5}}}}},
               {:t5, {:t4, {:foo, {:t2, :t1}}}}
             ) == {:error, :mismatch}

      assert TaggedTuple.untag(
               {:t6, {:t5, {:t4, {:t3, {:t2, {:t1, 2.5}}}}}},
               {:t6, {:t5, {:foo, {:t3, {:t2, :t1}}}}}
             ) == {:error, :mismatch}
    end

    test "accepts tag chain as a list" do
      assert TaggedTuple.untag({:t1, 2.5}, [:t1]) == {:ok, 2.5}
      assert TaggedTuple.untag({:t2, {:t1, 2.5}}, [:t2, :t1]) == {:ok, 2.5}
      assert TaggedTuple.untag({:t3, {:t2, {:t1, 2.5}}}, [:t3, :t2, :t1]) == {:ok, 2.5}

      assert TaggedTuple.untag({:t4, {:t3, {:t2, {:t1, 2.5}}}}, [:t4, :t3, :t2, :t1]) ==
               {:ok, 2.5}

      assert TaggedTuple.untag(
               {:t5, {:t4, {:t3, {:t2, {:t1, 2.5}}}}},
               [:t5, :t4, :t3, :t2, :t1]
             ) == {:ok, 2.5}

      assert TaggedTuple.untag(
               {:t6, {:t5, {:t4, {:t3, {:t2, {:t1, 2.5}}}}}},
               [:t6, :t5, :t4, :t3, :t2, :t1]
             ) == {:ok, 2.5}
    end
  end
end
