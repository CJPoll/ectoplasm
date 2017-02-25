defmodule Ectoplasm.Params do
  def determine_field_name(params, field) when is_atom(field) do
    cond do
      Map.has_key?(params, field) -> field
      Map.has_key?(params, Atom.to_string(field)) -> Atom.to_string(field)
      true -> raise "Field #{inspect field} not found in params"
    end
  end

  def delete(params, fields) when is_list(fields), do: delete_fields(params, fields)
  def delete(params, field) when is_atom(field), do: delete_field(params, field)

  def delete_fields(params, fields) when is_list(fields) do
    fields = Enum.map(fields, fn(field) -> determine_field_name(params, field) end)
    Map.drop(params, fields)
  end

  def delete_field(params, field) when is_atom(field) do
    delete_fields(params, [field])
  end

  def get_field(params, field) when is_atom(field) do
    field_name = determine_field_name(params, field)

    params[field_name]
  end

  def set_field(params, field, value) when is_atom(field) do
    field_name = determine_field_name(params, field)
    Map.put(params, field_name, value)
  end

  def set_length(val, desired_length) when is_list(val) and is_integer(desired_length) do
    set_length(val, desired_length, nil)
  end

  def set_length(val, desired_length) when is_binary(val) and is_integer(desired_length) do
    set_length(val, desired_length, "a")
  end

  def set_length(params, field, length) when is_map(params) and is_atom(field) do
    val =
      params
      |> get_field(field)
      |> set_length(length)

    set_field(params, field, val)
  end

  def set_length(val, desired_length, append_item) when is_list(val) and is_integer(desired_length) do
    case length(val) do
      len when len == desired_length -> val
      len when len > desired_length -> Enum.take(val, desired_length)
      len when len < desired_length ->
        val
        |> append_to_length(desired_length, append_item)
        |> set_length(desired_length, append_item)
    end
  end

  def set_length(val, desired_length, append_item) when is_binary(val) and is_integer(desired_length) do
    case String.length(val) do
      len when len == desired_length -> val
      len when len > desired_length -> String.slice(val, 0..(desired_length-1))
      len when len < desired_length ->
        val
        |> append_to_length(desired_length, append_item)
        |> set_length(desired_length, append_item)
    end
  end

  defp append_to_length(list, desired_len, append_item) when is_list(list) and is_integer(desired_len) do
    case length(list) do
      len when len < desired_len -> append_to_length([append_item | list], desired_len, append_item)
      _ -> list
    end
  end

  defp append_to_length(str, desired_len, append_item) when is_binary(str) and is_integer(desired_len) do
    case String.length(str) do
      len when len < desired_len -> append_to_length(str <> append_item, desired_len, append_item)
      _ -> str
    end
  end
end
