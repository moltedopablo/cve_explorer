defmodule CveExplorerWeb.CVELiveTest do
  use CveExplorerWeb.ConnCase

  import Phoenix.LiveViewTest
  import CveExplorer.ThreatIntelFixtures

  @create_attrs %{
    description: "some description",
    cve_id: "some cve_id",
    date_published: "2025-07-02T15:24:00Z",
    date_updated: "2025-07-02T15:24:00Z",
    raw_json: %{}
  }
  @update_attrs %{
    description: "some updated description",
    cve_id: "some updated cve_id",
    date_published: "2025-07-03T15:24:00Z",
    date_updated: "2025-07-03T15:24:00Z",
    raw_json: %{}
  }
  @invalid_attrs %{
    description: nil,
    cve_id: nil,
    date_published: nil,
    date_updated: nil,
    raw_json: nil
  }

  defp create_cve(_) do
    cve = cve_fixture()
    %{cve: cve}
  end

  describe "Index" do
    setup [:create_cve]

    test "lists all cves", %{conn: conn, cve: cve} do
      {:ok, _index_live, html} = live(conn, ~p"/cves")

      assert html =~ "Listing Cves"
      assert html =~ cve.description
    end
  end

  describe "Show" do
    setup [:create_cve]

    test "displays cve", %{conn: conn, cve: cve} do
      {:ok, _show_live, html} = live(conn, ~p"/cves/#{cve}")

      assert html =~ "Show Cve"
      assert html =~ cve.description
    end
  end
end
