defmodule Ectoplasm do
  @callback valid_params()  :: %{}
  @callback test_module()   :: module
  @callback repository()    :: module

  defmacro __using__(_) do
    quote do
      @behaviour Ectoplasm

      require Ectoplasm
      import Ectoplasm
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

  defmacro test_required(field, error_message \\ "can't be blank") do
    quote do
      test "must be present" do
        params = Map.delete(__MODULE__.valid_params(), unquote(field))
        struct = Kernel.struct!(@test_module)
        cs = @test_module.changeset(struct, params)
        refute cs.valid?
        assert {unquote(field), {unquote(error_message), []}} in cs.errors
      end
    end
  end

  defmacro test_unique(field, error_message \\ "has already been taken") do
    quote do
      test "must be present" do
        params = __MODULE__.valid_params()
        struct = Kernel.struct!(@test_module)
        cs = @test_module.changeset(struct, params)
        assert cs.valid?
        __MODULE__.repository.insert!(cs)
        {:error, cs} = __MODULE__.repository.insert(cs)
        assert {unquote(field), {unquote(error_message), []}} in cs.errors
      end
    end
  end

  defmacro valid_params(params) do
    quote do
      @valid_params unquote(params)
      def valid_params(), do: @valid_params
    end
  end
end
