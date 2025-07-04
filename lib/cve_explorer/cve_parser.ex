defmodule CveExplorer.CVEParser do
  defp extract_cve_metadata(decoded_json, key) do
    case decoded_json do
      %{
        "cveMetadata" => %{
          ^key => value
        }
      } ->
        {:ok, value}

      _ ->
        {:error, "Missing #{key}"}
    end
  end

  defp extract_description(decoded_json) do
    case decoded_json do
      %{
        "containers" => %{
          "cna" => %{
            "descriptions" => [
              %{"value" => description} | _rest
            ]
          }
        }
      } ->
        {:ok, description}

      _ ->
        {:error, "Missing description"}
    end
  end

  defp add_results({attrs, errors}, key, result) do
    case result do
      {:ok, value} ->
        {Map.put_new(attrs, key, value), errors}

      {:error, reason} ->
        {attrs, [reason | errors]}
    end
  end

  defp extract_fields(decoded_json) do
    {attrs, errors} =
      add_results({%{}, []}, "cve_id", extract_cve_metadata(decoded_json, "cveId"))
      |> add_results("date_published", extract_cve_metadata(decoded_json, "datePublished"))
      |> add_results("date_updated", extract_cve_metadata(decoded_json, "dateUpdated"))
      |> add_results("description", extract_description(decoded_json))

    if length(errors) == 0, do: {:ok, attrs}, else: {:error, errors}
  end

  def parse_cve(json) do
    with {:ok, decoded_json} <- Jason.decode(json),
         {:ok, attrs} <- extract_fields(decoded_json) do
      {:ok, Map.put_new(attrs, "raw_json", decoded_json)}
    end
  end
end
