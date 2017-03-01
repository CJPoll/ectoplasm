defmodule Ectoplasm do
  defmacro __using__(_) do
    quote do
      require Ectoplasm
      import Ectoplasm
    end
  end

  defmacro testing(module) do
    quote do
      @test_module unquote(module)
      def test_module(), do: @test_module
    end
  end

  defmacro exact_length(field, length, opts \\ [])

  defmacro exact_length(field, _length, _opts) when is_binary(field) do
    raise "exact_length/3 expects the field name to be an atom."
  end

  defmacro exact_length(field, length, _opts) when is_atom(field) do
    error_message = "should be #{length} character(s)"

    quote do
      test "must have a length of exactly #{inspect unquote(length)}", %{valid_params: params} do
        params = Ectoplasm.Params.set_length(params, unquote(field), unquote(length + 1))

        changeset = @test_module.changeset(%@test_module{}, params)

        assert {unquote(field), unquote(error_message)} in errors_on(changeset)
      end
    end
  end

  defmacro foreign_key(field, opts \\ [])

  defmacro foreign_key(field, opts) do
    error_message = Keyword.get(opts, :message, "does not exist")

    quote do
      test "must be a foreign key", %{valid_params: params} do
        params = Ectoplasm.Params.set_field(params, unquote(field), -1)
        repo = Ectoplasm.get_repo!

        {status, changeset} =
          %@test_module{}
          |> @test_module.changeset(params)
          |> repo.insert

        assert {unquote(field), unquote(error_message)} in errors_on(changeset)
      end
    end
  end

  defmacro included_in(field, inclusions, alternate, opts \\ [])

  defmacro included_in(field, inclusions, alternate, opts) when is_list(inclusions) do
    error_message = Keyword.get(opts, :message, "is invalid")

    quote do
      test "only accepts certain values", %{valid_params: params} do
        params = Ectoplasm.Params.set_field(params, unquote(field), unquote(alternate))

        changeset = @test_module.changeset(%@test_module{}, params)

        if changeset.valid? do
          raise "Expected setting #{inspect unquote(field)} to #{inspect unquote(alternate)} to invalidate the changeset. It should only accept values in #{inspect unquote(inclusions)}"
        end

        assert {unquote(field), unquote(error_message)} in errors_on(changeset)
      end
    end
  end

  defmacro maximum_length(field, length, opts \\ [])

  defmacro maximum_length(field, _length, _opts) when is_binary(field) do
    raise "maximum_length/3 expects the field name to be an atom."
  end

  defmacro maximum_length(field, length, _opts) when is_atom(field) do
    error_message = "should be at most #{length} character(s)"

    quote do
      test "must have a length of at most #{inspect unquote(length)}", %{valid_params: params} do
        params = Ectoplasm.Params.set_length(params, unquote(field), unquote(length + 1))

        changeset = @test_module.changeset(%@test_module{}, params)

        assert {unquote(field), unquote(error_message)} in errors_on(changeset)
      end
    end
  end

  defmacro minimum_length(field, length, opts \\ [])

  defmacro minimum_length(field, _length, _opts) when is_binary(field) do
    raise "minimum_length/3 expects the field name to be an atom."
  end

  defmacro minimum_length(field, length, _opts) when is_atom(field) do
    error_message = "should be at least #{length} character(s)"

    quote do
      test "must have a length of at least #{inspect unquote(length)}", %{valid_params: params} do
        params = Ectoplasm.Params.set_length(params, unquote(field), unquote(length - 1))

        changeset = @test_module.changeset(%@test_module{}, params)

        assert {unquote(field), unquote(error_message)} in errors_on(changeset)
      end
    end
  end

  defmacro must_match(field, confirmation_field, opts \\ [])

  defmacro must_match(field, confirmation_field, _opts) when is_binary(field) or is_binary(confirmation_field) do
    raise "must_match/3 expects the 2 field names to be atoms."
  end

  defmacro must_match(field, confirmation_field, opts) when is_atom(field) and is_atom(confirmation_field) do
    error_message = Keyword.get(opts, :message, "does not match confirmation")

      quote do
        test "must match #{inspect unquote(confirmation_field)}", %{valid_params: params} do
          params = Ectoplasm.Params.delete_field(params, unquote(field))

          changeset = @test_module.changeset(%@test_module{}, params)

          assert {unquote(confirmation_field), unquote(error_message)} in errors_on(changeset)
        end
      end
  end

  defmacro optional_field(field) when is_binary(field) do
    raise "optional_field/2 requires the field name to be an atom, not a string. Found: #{field}"
  end

  defmacro optional_field(field) when is_atom(field) do
    quote do
      test "is optional", %{valid_params: params} do
        params = Ectoplasm.Params.delete_field(params, unquote(field))

        changeset = @test_module.changeset(%@test_module{}, params)

        unless changeset.valid? do
          raise "Expected #{inspect unquote(field)} to be optional, but was required"
        end
      end
    end
  end

  defmacro required_field(field, opts \\ [])

  defmacro required_field(field, _opts) when is_binary(field) do
    raise "required_field/2 requires the field name to be an atom, not a string. Found: #{field}"
  end

  defmacro required_field(field, opts) when is_atom(field) do
    error_message = Keyword.get(opts, :message, "can't be blank")

    quote do
      test "is required", %{valid_params: params} do
        params = Ectoplasm.Params.delete_field(params, unquote(field))

        changeset = @test_module.changeset(%@test_module{}, params)

        assert {unquote(field), unquote(error_message)} in errors_on(changeset)
      end

      test "can not be blank", %{valid_params: params} do
        params =
          params
          |> Map.delete(unquote(field))
          |> Map.delete(unquote(Atom.to_string(field)))

        changeset = @test_module.changeset(%@test_module{}, params)

        assert {unquote(field), unquote(error_message)} in errors_on(changeset)
      end
    end
  end

  defmacro scope_by(field, alternate_value) when is_atom(field) do
    quote do
      test "scopes a query to a specific value for #{inspect unquote(field)}", %{valid_params: params} do
        if Ectoplasm.Params.get_field(params, unquote(field)) == unquote(alternate_value) do
          raise "scope_by/2 requires that the alternate value be different from the value in valid_params"
        end
        repo = Ectoplasm.get_repo!

        %@test_module{}
        |> @test_module.changeset(params)
        |> repo.insert!

        %@test_module{}
        |> @test_module.changeset(params |> Ectoplasm.Params.set_field(unquote(field), unquote(alternate_value)))
        |> repo.insert!

        query = @test_module

        model =
          @test_module
          |> apply(:"with_#{unquote(field)}", [query, unquote(alternate_value)])
          |> repo.one

        assert model
        assert Map.get(model, unquote(field)) == unquote(alternate_value)
      end
    end
  end

  defmacro unique_field(field, opts \\ [])

  defmacro unique_field(field, _opts) when is_binary(field) do
    raise "unique_field/2 requires the field name to be an atom, not a string. Found: #{field}"
  end

  defmacro unique_field(field, opts) when is_atom(field) do
    error_message = Keyword.get(opts, :message, "has already been taken")

    quote do
      test "must be unique", %{valid_params: params} do
        changeset = @test_module.changeset(%@test_module{}, params)

        repo = Ectoplasm.get_repo!
        repo.insert!(changeset)

        case repo.insert(changeset) do
          {:error, changeset} ->
            assert {unquote(field), unquote(error_message)} in errors_on(changeset)
          {:ok, model} ->
            raise "Expected #{inspect unquote(field)} to have a unique constraint."
        end
      end
    end
  end

  defmacro validate_params! do
    quote do
      test "valid_params must be valid", %{valid_params: params} do
        changeset = @test_module.changeset(%@test_module{}, params)

        repo = Ectoplasm.get_repo!

        case repo.insert(changeset) do
          {:ok, _} -> :ok
          {:error, changeset} ->
            raise "Expected valid_params to validate, but validation failed: #{inspect errors_on(changeset)}"
        end
      end
    end
  end

  defmacro has_error?(%Ecto.Changeset{} = changeset, field, error_message) do
    quote do
      has_error?(errors_on(unquote(changeset)), unquote(field), unquote(error_message))
    end
  end

  defmacro has_error?(errors, field, error_message) do
    quote do
      assert {unquote(field), unquote(error_message)} in unquote(errors)
    end
  end

  def errors_on(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.flat_map(fn {key, errors} -> for msg <- errors, do: {key, msg} end)
  end

  def get_repo! do
    repo = Application.get_env(:ectoplasm, :repository)

    if repo == nil do
      raise """
      You need to configure ectplasm to see your repository in test.exs:

      config :ectoplasm, repository: YourApp.Repo
      """
    end

    repo
  end
end
