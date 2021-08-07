# TaggedTuple

[![Build Status](https://travis-ci.com/IvanRublev/tagged_tuple.svg?branch=master)](https://travis-ci.com/IvanRublev/tagged_tuple)
[![Coverage Status](https://coveralls.io/repos/github/IvanRublev/tagged_tuple/badge.svg)](https://coveralls.io/github/IvanRublev/tagged_tuple)
[![hex.pm version](http://img.shields.io/hexpm/v/tagged_tuple.svg?style=flat)](https://hex.pm/packages/tagged_tuple)

> Full documentation is on [hexdocs.pm](https://hexdocs.pm/tagged_tuple/)

[//]: # (Documentation)

A library to work with tagged tuples.

Tagged tuple is a tuple attaching a tag to a value `{tag, value}`.
Common tagged tuples are `{:ok, value}` and `{:error, message}` returned
from the functions.

## Tag chains

A chain of tags can be attached to a single core value by nesting
tagged tuples in each other.

For example, `{:units, {:boxes, 1}}` and `{:units, {:kilograms, 2.5}}`
tagged tuples describe the same deliverable item with different measures.

The tag chains of `:units` - `:boxes` and `:units` - `:kilograms`
can be efficiently pattern matched then to handle core values of
different types appropriately.

[//]: # (Documentation)

## Usage example

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

## Changelog

### 1.0.0
* Inintial release

## License

Copyright © 2021 Ivan Rublev

This project is licensed under the [MIT license](LICENSE).
