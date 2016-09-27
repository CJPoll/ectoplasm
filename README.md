# Ectoplasm

A thin DSL for testing ecto models

## Installation

In your mix.exs:

```elixir
defp deps() do
	[
		{:ectoplasm, git: "git@github.com:cjpoll/ectoplasm"}, # It's not on hex yet
		...
	]
end
```

## Usage

```elixir
defmodule MyApp.User.Test do
	use MyApp.ModelCase
	use Ectoplasm

	repo MyApp.Repo
	testing MyApp.User
	valid_params %{email: "myemail@gmail.com"}

	describe "email" do
		test_required(:email)
		test_unique(:email)
	end
end
```
