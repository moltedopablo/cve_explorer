defmodule CveExplorerWeb.CVELiveTest do
  use CveExplorerWeb.ConnCase

  import Phoenix.LiveViewTest
  import CveExplorer.ThreatIntelFixtures
  alias CveExplorerWeb.Test.Utils.CVEJSON

  defp create_cve(_) do
    cve = cve_fixture()
    %{cve: cve}
  end

  describe "Index" do
    setup [:create_cve]

    test "lists all cves", %{conn: conn, cve: cve} do
      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "Listing Cves"
      assert html =~ cve.cve_id
    end

    test "list all cves order by date_published", %{conn: conn} do
      cve1 = cve_fixture(%{cve_id: "CVE-2025-00001", date_published: ~U[2025-07-01 15:24:00Z]})
      cve2 = cve_fixture(%{cve_id: "CVE-2025-00002", date_published: ~U[2025-07-02 15:24:00Z]})

      {:ok, index_live, _html} = live(conn, ~p"/")

      table_html =
        index_live
        |> element("table")
        |> render()

      assert table_html =~ cve1.cve_id
      assert table_html =~ cve2.cve_id

      # Check that content before cve2 is shorter than before cve1
      # This ensures that cve2 appears before cve1 in the rendered HTML
      before_cve1 = table_html |> String.split(cve1.cve_id) |> List.first() |> String.length()
      before_cve2 = table_html |> String.split(cve2.cve_id) |> List.first() |> String.length()

      assert before_cve2 < before_cve1
    end

    test "navigates to upload new CVEs page when clicking Upload new CVEs", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      assert {:ok, new_live, _html} = 
        index_live
        |> element("a", "Upload new CVEs")
        |> render_click()
        |> follow_redirect(conn, ~p"/cves/new")

      assert has_element?(new_live, "#upload-form")
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

  describe "File Upload" do
    test "uploads a single valid CVE JSON file successfully", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cves/new")

      file = %{
        last_modified: System.system_time(:millisecond),
        name: "cve-2025-12345.json",
        content: CVEJSON.valid(),
        size: byte_size(CVEJSON.valid()),
        content_type: "application/json"
      }

      index_live
      |> file_input("#upload-form", :raw_json, [file])
      |> render_upload("cve-2025-12345.json")

      index_live
      |> form("#upload-form")
      |> render_submit()

      assert has_element?(
               index_live,
               "#files-upload-result .text-success",
               "File uploaded successfully"
             )

      assert CveExplorer.ThreatIntel.get_cve_by_cve_id("CVE-2025-12345") != {:error, :not_found}
    end

    test "handles invalid JSON format gracefully", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cves/new")

      file = %{
        last_modified: System.system_time(:millisecond),
        name: "invalid.json",
        content: CVEJSON.invalid_json_format(),
        size: byte_size(CVEJSON.invalid_json_format()),
        content_type: "application/json"
      }

      index_live
      |> file_input("#upload-form", :raw_json, [file])
      |> render_upload("invalid.json")

      index_live
      |> form("#upload-form")
      |> render_submit()

      assert has_element?(
               index_live,
               "#files-upload-result .text-error",
               "Invalid JSON format"
             )
    end

    test "handles missing required fields in CVE JSON", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cves/new")

      file = %{
        last_modified: System.system_time(:millisecond),
        name: "missing-cve-id.json",
        content: CVEJSON.missing_cve_id(),
        size: byte_size(CVEJSON.missing_cve_id()),
        content_type: "application/json"
      }

      index_live
      |> file_input("#upload-form", :raw_json, [file])
      |> render_upload("missing-cve-id.json")

      index_live
      |> form("#upload-form")
      |> render_submit()

      assert has_element?(
               index_live,
               "#files-upload-result .text-error",
               "Missing cveId"
             )
    end

    test "handles non-JSON file uploads", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cves/new")

      file = %{
        last_modified: System.system_time(:millisecond),
        name: "document.txt",
        content: "This is a text file, not JSON",
        size: byte_size("This is a text file, not JSON"),
        content_type: "text/plain"
      }

      index_live
      |> file_input("#upload-form", :raw_json, [file])
      |> render_upload("document.txt")

      assert has_element?(
               index_live,
               "#files-to-upload .alert-error",
               "You have selected an unacceptable file type"
             )
    end
  end
end
