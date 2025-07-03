defmodule CveExplorer.CVEParser do
  def parse_cve(json) do
    with {:ok, decoded_json} <- Jason.decode(json),
         {:ok,
          %{
            "cveMetadata" => %{
              "cveId" => cve_id,
              "datePublished" => date_published,
              "dateUpdated" => date_updated
            },
            "containers" => %{
              "cna" => %{
                "descriptions" => [
                  %{"value" => description} | _rest
                ]
              }
            }
          }} <- {:ok, decoded_json} do
      %{
        cve_id: cve_id,
        date_published: date_published,
        date_updated: date_updated,
        description: description,
        raw_json: decoded_json
      }
    end
  end
end
