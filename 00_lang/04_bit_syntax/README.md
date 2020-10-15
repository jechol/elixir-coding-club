## charlist <-> string 변환을 직접 구현하고 bit syntax 를 제대로 익혀봅시다.

Reference:

1. Wiki : https://en.wikipedia.org/wiki/UTF-8
2. Erlang : http://erlang.org/doc/programming_examples/bit_syntax.html
3. Elixir : https://elixir-lang.org/getting-started/binaries-strings-and-char-lists.html

## 1. Unicode integer <-> Utf8 binary

lib/utf8.ex 내용을 채워봅시다.

## 2. Uncode charlist <-> Utf8 binary

1에서 만든 함수를 사용하여

1. Kernel.to_charlist/1 와 동일한 기능을 하는 Charlist.string_to_charlist
2. Kernel.to_string/1 와 동일한 기능을 하는 Charlist.charlist_to_string

을 lib/charlist.ex 에 구현합시다.
