defmodule Ectoplasm.Model do
  defmacro __using__(_) do
    quote do
      require Ectoplasm.Model
      import Ectoplasm.Model
    end
  end

  defmacro lookup_by(field) when is_atom(field) do
    quote do
      def unquote(:"with_#{field}")(query, val) do
        Ecto.Query.where(query, [{unquote(field), ^val}])
      end
    end
  end
end
