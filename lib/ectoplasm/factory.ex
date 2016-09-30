defmodule Ectoplasm.Factory do
  @type params :: map

  @callback product       :: module
  @callback valid_params  :: params

  defmacro __using__(_) do
    quote do
      @behaviour Ectoplasm.Factory

      require Ectoplasm.Factory
      import Ectoplasm.Factory
    end
  end

  defmacro builds(module) do
    quote do
      @product unquote(module)
      def product(), do: @product
    end
  end

  def do_valid_params(do: body) do
    quote do
      def valid_params() do
        unquote(body)
      end

      def create!(params \\ %{}) do
        params
        |> Enum.map(fn
          ({k, v}) when is_atom(k) -> {Atom.to_string(k), v}
          ({k, v}) when is_binary(k) -> {k, v}
        end)
        |> Map.new
        params = Map.merge(valid_params(), params)
        struct = Kernel.struct!(@product)
        cs = @product.changeset(struct, params)
        __MODULE__.repository.insert!(cs)
      end
    end
  end

  defmacro repo(repo) do
    quote do
      @repository unquote(repo)
      def repository(), do: @repository
    end
  end

  defmacro valid_params(do: body) do
    do_valid_params(do: body)
  end

  defmacro valid_params(params) do
    do_valid_params(do: params)
  end
end
