# Pretty printing for Elixir

This pretty printer is inspired in the `pp` macro from Crystal: [https://crystal-lang.org/api/toplevel.html#pp%28%2Aexps%29-macro]. It's quite useful while doing print debugging.

## Installation

The package can be installed by adding `pp` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pp, "~> 0.1.0"}
  ]
end
```

## Usage

In order to use the `pp` macro, first import the `PP` module in your code:

```elixir
import PP
```

Now you're ready to use the macro:

```elixir
x = 1
y = 2
pp x + y, :red
```

When that code is executed, it will print in the console in red color:

```
x + y # => 3
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/pp](https://hexdocs.pm/pp).

