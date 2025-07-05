defmodule CveExplorerWeb.APIControllerTest do
  use CveExplorerWeb.ConnCase

  import CveExplorer.ThreatIntelFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all cves when empty", %{conn: conn} do
      conn = get(conn, ~p"/api/cves")
      assert json_response(conn, 200)["data"] == []
    end

    test "lists several cves", %{conn: conn} do
      cve_fixture(%{cve_id: "CVE-2025-11111"})
      cve_fixture(%{cve_id: "CVE-2025-22222"})
      cve_fixture(%{cve_id: "CVE-2025-33333"})

      conn = get(conn, ~p"/api/cves")
      response = json_response(conn, 200)["data"]

      assert length(response) == 3
      cve_ids = Enum.map(response, & &1["cve_id"])
      assert "CVE-2025-11111" in cve_ids
      assert "CVE-2025-22222" in cve_ids
      assert "CVE-2025-33333" in cve_ids
    end
  end

  describe "raw_json" do
    test "returns the complete raw JSON for an existing CVE", %{conn: conn} do
      cve =
        cve_fixture(%{
          cve_id: "CVE-2025-44444",
          raw_json: %{
            "containers" => %{
              "cna" => %{
                "descriptions" => [
                  %{
                    "lang" => "en",
                    "value" => "Test vulnerability description"
                  }
                ]
              }
            },
            "cveMetadata" => %{
              "cveId" => "CVE-2025-44444",
              "dateUpdated" => "2025-07-02T15:24:00Z",
              "datePublished" => "2025-07-02T15:24:00Z"
            }
          }
        })

      conn = get(conn, ~p"/api/cves/#{cve.cve_id}")
      response = json_response(conn, 200)

      assert response["cveMetadata"]["cveId"] == "CVE-2025-44444"

      assert response["containers"]["cna"]["descriptions"] == [
               %{"lang" => "en", "value" => "Test vulnerability description"}
             ]
    end

    test "returns 404 when CVE does not exist", %{conn: conn} do
      conn = get(conn, ~p"/api/cves/CVE-2025-99999")
      assert json_response(conn, 404)["errors"] != %{}
    end
  end
end
