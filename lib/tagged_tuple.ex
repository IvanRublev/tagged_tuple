defmodule TaggedTuple do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("[//]: # (Documentation)\n")
             |> Enum.at(1)
             |> String.trim("\n")

  defmacro __using__(_opts) do
    quote do
      require unquote(__MODULE__)

      import unquote(__MODULE__),
        only: [
          ---: 2
        ]
    end
  end

  @doc """
  Defines a tagged tuple. It's equivalent to `{tag, value}`.

  The operator is right-associative. When it's called several times in a row,
  it assembles a tag chain with a value in the core.

      :x --- :y --- :z --- "value" == {:x, {:y, {:z, "value"}}}

  Can be used in Expressions and Pattern Matchings.

  ## Examples

      iex> use TaggedTuple
      ...> :tag --- 12
      {:tag, 12}
      ...> tagged_tuple = :a --- :tag --- :chain --- 12
      {:a, {:tag, {:chain, 12}}}
      ...> match?(:a --- :tag --- _tail, tagged_tuple)
      true
      ...> :a --- t1 --- t2 --- core_value = tagged_tuple
      ...> t1 == :tag
      ...> t2 == :chain
      ...> core_value == 12
  """
  # credo:disable-for-next-line
  defmacro tag --- value do
    quote do
      {unquote(tag), unquote(value)}
    end
  end

  defguardp not_tuple(t1)
            when not is_tuple(t1)

  defguardp not_tuple(t2, t1)
            when not is_tuple(t2) and not is_tuple(t1)

  defguardp not_tuple(t3, t2, t1)
            when not is_tuple(t3) and not is_tuple(t2) and not is_tuple(t1)

  defguardp not_tuple(t4, t3, t2, t1)
            when not is_tuple(t4) and not is_tuple(t3) and not is_tuple(t2) and not is_tuple(t1)

  defguardp not_tuple(t5, t4, t3, t2, t1)
            when not is_tuple(t5) and not is_tuple(t4) and not is_tuple(t3) and not is_tuple(t2) and
                   not is_tuple(t1)

  @doc """
  Returns a tagged tuple by attaching the tag chain to the core value.

  `tag_chain` can be a nested tuple with tags returned from the `split/1`
   or a list with tags.

  ## Example

      iex> TaggedTuple.tag(2.5, :some_tag)
      {:some_tag, 2.5}

      iex> TaggedTuple.tag(7, {:a, {:tag, :chain}})
      {:a, {:tag, {:chain, 7}}}

      iex> TaggedTuple.tag(7, [:a, :tag, :chain])
      {:a, {:tag, {:chain, 7}}}
  """
  def tag(value, tag_chain)

  def tag(v, []), do: v

  def tag(v, [_ | _] = tag_chain) do
    tag_chain
    |> List.insert_at(-1, v)
    |> from_list()
  end

  def tag(v, t1) when not_tuple(t1),
    do: {t1, v}

  def tag(v, {t2, t1}) when not_tuple(t2, t1),
    do: {t2, {t1, v}}

  def tag(v, {t3, {t2, t1}}) when not_tuple(t3, t2, t1),
    do: {t3, {t2, {t1, v}}}

  def tag(v, {t4, {t3, {t2, t1}}}) when not_tuple(t4, t3, t2, t1),
    do: {t4, {t3, {t2, {t1, v}}}}

  def tag(v, {t5, {t4, {t3, {t2, t1}}}}) when not_tuple(t5, t4, t3, t2, t1),
    do: {t5, {t4, {t3, {t2, {t1, v}}}}}

  def tag(v, tag_chain) when tuple_size(tag_chain) == 2 do
    tag_chain
    |> to_list()
    |> List.insert_at(-1, v)
    |> from_list()
  end

  @doc """
  Removes the given subchain from the tag chain's beginning and return the
  tagged tuple built from the rest. When the full tag chain is given,
  it returns the core value.

  Raises `ArgumentError` exception if the passed tag subchain doesn't match
  the begginning of the tag chain of the tagged tuple.

  `tag_chain` can be a nested tuple with tags returned from the `split/1`
  or a list with tags.

  ## Examples

      iex> value = {:a, {:tag, {:chain, 2}}}
      iex> TaggedTuple.untag!(value, :a)
      {:tag, {:chain, 2}}
      iex> TaggedTuple.untag!(value, {:a, :tag})
      {:chain, 2}
      iex> TaggedTuple.untag!(value, {:a, {:tag, :chain}})
      2
      iex> TaggedTuple.untag!(value, [:a, :tag, :chain])
      2
      iex> value = {:other, {:stuff, 2}}
      ...> TaggedTuple.untag!(value, {:a, {:tag, :chain}})
      ** (ArgumentError) Tag chain {:a, {:tag, :chain}} doesn't match one in the tagged tuple {:other, {:stuff, 2}}.

  """
  def untag!(tagged_tuple, tag_chain) do
    case untag(tagged_tuple, tag_chain) do
      {:ok, value} ->
        value

      {:error, :mismatch} ->
        Kernel.raise(ArgumentError, """
        Tag chain #{inspect(tag_chain)} doesn't match one in \
        the tagged tuple #{inspect(tagged_tuple)}.\
        """)
    end
  end

  @doc """
  Same as `untag!/2`.

  Returns `{:error, :mismatch}` when `tag_chain` doesn't match
  the beginning part of the tag chain of the tagged tuple.
  """
  def untag(tagged_tuple, tag_chain)

  def untag({t1, value}, [t1]) do
    {:ok, value}
  end

  def untag({t1, tail}, [t1 | rest]) do
    untag(tail, rest)
  end

  def untag({t1, value}, t1) do
    {:ok, value}
  end

  def untag({t1, tail}, {t1, rest}) do
    untag(tail, rest)
  end

  def untag(_, _) do
    {:error, :mismatch}
  end

  @doc """
  Returns the tag chain and the core value from the given tagged tuple.

  ## Examples

      iex> {chain, value} = TaggedTuple.split({:a, {:tag, {:chain, 2}}})
      ...> chain == {:a, {:tag, :chain}}
      ...> value == 2
      iex> TaggedTuple.tag(value, chain)
      {:a, {:tag, {:chain, 2}}}
  """
  def split(tagged_tuple) when is_tuple(tagged_tuple) do
    list = to_list(tagged_tuple)

    value = List.last(list)

    tags =
      case List.delete_at(list, -1) do
        [one] -> one
        [_ | _] = many -> from_list(many)
      end

    {tags, value}
  end

  @doc """
  Converts a tagged tuple to a list.

  The `tag_fun` will be invoked with each tag, and the result will be inserted
  into the list. The `value_fun` will be invoked with the tagged tuple's
  core value, and the result will be inserted into the list.

  ## Examples

      iex> TaggedTuple.to_list({:a, {:tag, {:chain, 2}}})
      [:a, :tag, :chain, 2]

      iex> TaggedTuple.to_list({:a, {:tag, {:chain, 2}}}, &to_string/1, &(&1 * 100))
      ["a", "tag", "chain", 200]
  """
  def to_list(tagged_tuple, tag_fun \\ fn x -> x end, value_fun \\ fn y -> y end) do
    do_to_list(tagged_tuple, tag_fun, value_fun, [])
  end

  defp do_to_list({head, tail}, tag_fun, value_fun, acc),
    do: do_to_list(tail, tag_fun, value_fun, [tag_fun.(head) | acc])

  defp do_to_list(value, _tag_fun, value_fun, acc), do: Enum.reverse([value_fun.(value) | acc])

  @doc """
  Converts a list to a tagged tuple.

  The list must have at least two elements, a tag and a value, respectfully.

  The `tag_fun` will be invoked with each tag, and the result will be added
  to the tuple. The `value_fun` will be invoked with the core value, and
  the result will be added to the tuple.

  ## Examples

      iex> TaggedTuple.from_list([:a, :tag, :chain, 2])
      {:a, {:tag, {:chain, 2}}}

      iex> TaggedTuple.from_list(["a", "tag", "chain", 200], &String.to_existing_atom/1, &div(&1, 100))
      {:a, {:tag, {:chain, 2}}}
  """
  def from_list(list, tag_fun \\ fn x -> x end, value_fun \\ fn y -> y end)

  def from_list([tag], tag_fun, _value_fun) do
    tag_fun.(tag)
  end

  def from_list(list, tag_fun, value_fun) do
    [value, tag | tail] = Enum.reverse(list)
    do_from_list(tail, tag_fun, {tag_fun.(tag), value_fun.(value)})
  end

  defp do_from_list([tag | tail], tag_fun, acc) do
    do_from_list(tail, tag_fun, {tag_fun.(tag), acc})
  end

  defp do_from_list([], _tag_fun, acc) do
    acc
  end

  @doc """
  Converts a tagged tuple to a map.

  The returned map can be encoded into a JSON to transmit over the network
  or persist in a database.

  The `tag_fun` will be invoked with each tag, and the result will be inserted
  into the map. The `value_fun` will be invoked with the tagged tuple's
  core value, and the result will be inserted into the map.

  ## Examples

      iex> TaggedTuple.to_map({:a, {:tag, {:chain, 2}}})
      %{a: %{tag: %{chain: 2}}}

      iex> TaggedTuple.to_map({:a, {:tag, {:chain, 2}}}, &to_string/1, &(&1 * 100))
      %{"a" => %{"tag" => %{"chain" => 200}}}
  """
  def to_map(tagged_tuple, tag_fun \\ fn x -> x end, value_fun \\ fn y -> y end)
      when is_tuple(tagged_tuple) do
    [value, tag | tail] =
      tagged_tuple
      |> to_list()
      |> Enum.reverse()

    do_to_map(tail, tag_fun, %{tag_fun.(tag) => value_fun.(value)})
  end

  defp do_to_map([tag | tail], tag_fun, acc),
    do: do_to_map(tail, tag_fun, %{tag_fun.(tag) => acc})

  defp do_to_map([], _tag_fun, acc), do: acc

  @doc """
  Converts a map to a tagged tuple.

  The `tag_fun` will be invoked with each tag, and the result will be added
  to the tuple. The `value_fun` will be invoked with the core value,
  and the result will be added to the tuple.

  ## Examples

      iex> TaggedTuple.from_map(%{a: %{tag: %{chain: 2}}})
      {:a, {:tag, {:chain, 2}}}

      iex> TaggedTuple.from_map(%{"a" => %{"tag" => %{"chain" => 20}}}, &String.to_existing_atom/1, &div(&1, 10))
      {:a, {:tag, {:chain, 2}}}
  """
  def from_map(map, tag_fun \\ fn x -> x end, value_fun \\ fn y -> y end) do
    do_from_map(map, tag_fun, value_fun, [])
  end

  defp do_from_map(%{} = map, tag_fun, value_fun, acc) do
    {tag1, tail} = Enum.at(map, 0)
    do_from_map(tail, tag_fun, value_fun, [tag_fun.(tag1) | acc])
  end

  defp do_from_map(value, _tag_fun, value_fun, acc) do
    [value_fun.(value) | acc]
    |> Enum.reverse()
    |> from_list()
  end
end
