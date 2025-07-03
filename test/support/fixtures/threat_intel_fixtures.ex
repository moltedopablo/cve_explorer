defmodule CveExplorer.ThreatIntelFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CveExplorer.ThreatIntel` context.
  """

  @doc """
  Generate a unique cve cve_id.
  """
  def unique_cve_cve_id, do: "some cve_id#{System.unique_integer([:positive])}"

  @doc """
  Generate a cve.
  """
  def cve_fixture(attrs \\ %{}) do
    {:ok, cve} =
      attrs
      |> Enum.into(%{
        cve_id: unique_cve_cve_id(),
        date_published: ~U[2025-07-02 15:24:00Z],
        date_updated: ~U[2025-07-02 15:24:00Z],
        description: "some description",
        raw_json: %{}
      })
      |> CveExplorer.ThreatIntel.create_cve()

    cve
  end
end
