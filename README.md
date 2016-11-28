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

## License

MIT License

Copyright (c) 2017 Cody J. Poll

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
