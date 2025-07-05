defmodule CveExplorer.ThreatIntelFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CveExplorer.ThreatIntel` context.
  """

  @doc """
  Generate a unique cve cve_id.
  """
  # CVE-2025-33053
  def unique_cve_cve_id, do: "CVE-#{System.unique_integer([:positive])}"

  @doc """
  Generate a cve.
  """
  def cve_fixture(attrs \\ %{}) do
    {:ok, cve} =
      attrs
      |> Enum.into(%{
        cve_id: "CVE-2025-12345",
        date_published: ~U[2025-07-02 15:24:00Z],
        date_updated: ~U[2025-07-02 15:24:00Z],
        description: "Some description of the vulnerability.",
        raw_json: %{
          "containers" => %{
            "cna" => %{
              "descriptions" => [
                %{
                  "lang" => "en",
                  "value" => "Some description of the vulnerability."
                }
              ]
            }
          },
          "cveMetadata" => %{
            "cveId" => "CVE-2025-12345",
            "dateUpdated" => "2025-07-02 15:24:00Z",
            "datePublished" => "2025-07-02 15:24:00Z"
          }
        }
      })
      |> CveExplorer.ThreatIntel.create_cve()

    cve
  end
end
