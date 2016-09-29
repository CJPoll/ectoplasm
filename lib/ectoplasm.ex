defmodule Ectoplasm do
  @callback test_module()   :: module
  @callback repository()    :: module
  @callback factory()       :: module

  defmacro __using__(_) do
    quote do
      @behaviour Ectoplasm

      require Ectoplasm
      import Ectoplasm
    end
  end

  defmacro factory(module) do
    quote do
      @factory unquote(module)
      def factory(), do: @factory
    end
  end

  defmacro repo(repo) do
    quote do
      @repository unquote(repo)
      def repository(), do: @repository
    end
  end

  defmacro testing(module) do
    quote do
      @test_module unquote(module)
      def test_module(), do: @test_module
    end
  end

  defmacro test_foreign_key(field) do
    quote do
      test "must be a foreign key" do
        params =
          @factory.valid_params()
          |> Map.update(unquote(field), 99999, fn(_) -> 99999 end)

        struct = Kernel.struct!(@test_module)
        cs = @test_module.changeset(struct, params)
        {status, changeset} = @repository.insert(cs)

        assert {unquote(field), {"does not exist", []}} in changeset.errors
      end
    end
  end

  defmacro test_required(field, error_message \\ "can't be blank") do
    quote do
      test "must be present" do
        params =
          @factory.valid_params()
          |> Map.delete(unquote(field))
          |> Map.delete(Atom.to_string(unquote(field)))

        struct = Kernel.struct!(@test_module)
        cs = @test_module.changeset(struct, params)
        refute cs.valid?
        assert {unquote(field), {unquote(error_message), []}} in cs.errors
      end
    end
  end

  defmacro test_unique(field, error_message \\ "has already been taken") do
    quote do
      test "must be unique" do
        params = @factory.valid_params()
        struct = Kernel.struct!(@test_module)
        cs = @test_module.changeset(struct, params)
        assert cs.valid?
        __MODULE__.repository.insert!(cs)

        case __MODULE__.repository.insert(cs) do
          {:error, cs} ->
            assert {unquote(field), {unquote(error_message), []}} in cs.errors
          _ -> flunk
        end

      end
    end
  end

  defmacro validate_factory! do
    quote do
      test "valid_params must be valid" do
        params = @factory.valid_params()
        struct = Kernel.struct!(@test_module)
        cs = @test_module.changeset(struct, params)
        assert cs.valid?
      end
    end
  end
end
