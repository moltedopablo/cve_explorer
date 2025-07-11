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
               "#files-to-upload .text-error",
               "You have selected an unacceptable file type"
             )
    end

    test "navigates to list after clicking go back to list after upload", %{conn: conn} do
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

      assert {:ok, new_live, _html} =
               index_live
               |> element("#go-back-button", "Go back to list")
               |> render_click()
               |> follow_redirect(conn, ~p"/")

      assert has_element?(new_live, ".card-title", "CVE Explorer List")
    end

    test "disables upload button when there are files with errors", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cves/new")

      assert index_live
             |> element("button[type='submit']")
             |> render()
             |> String.contains?("disabled")

      # Upload a non-JSON file which should trigger an error
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
               "#files-to-upload .text-error",
               "You have selected an unacceptable file type"
             )

      assert index_live
             |> element("button[type='submit']")
             |> render()
             |> String.contains?("disabled")
    end

    test "enables upload button when valid files are selected", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cves/new")

      assert index_live
             |> element("button[type='submit']")
             |> render()
             |> String.contains?("disabled")

      # Upload a valid JSON file
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

      # Verify the upload button is now enabled (not disabled)
      refute index_live
             |> element("button[type='submit']")
             |> render()
             |> String.contains?("disabled")
    end

    test "upload result section only shows when no files are pending upload", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cves/new")

      refute has_element?(index_live, "#files-upload-result")

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

      refute has_element?(index_live, "#files-upload-result")
      assert has_element?(index_live, "#files-to-upload")

      index_live
      |> form("#upload-form")
      |> render_submit()

      assert has_element?(index_live, "#files-upload-result")

      assert has_element?(
               index_live,
               "#files-upload-result .text-success",
               "File uploaded successfully"
             )

      refute has_element?(index_live, "#files-to-upload")
    end

    test "upload results clear when new files are added", %{conn: conn} do
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

      assert has_element?(index_live, "#files-upload-result")

      assert has_element?(
               index_live,
               "#files-upload-result .text-success",
               "File uploaded successfully"
             )

      # Trigger the new-files event by adding a new file to the file input
      index_live
      |> file_input("#upload-form", :raw_json, [file])
      |> render_upload("cve-2025-12345.json")

      # Verify upload results are cleared and files-to-upload section is shown
      refute has_element?(index_live, "#files-upload-result")
      assert has_element?(index_live, "#files-to-upload")
    end

    test "shows general error when uploading more than 10 files", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cves/new")

      files =
        Enum.map(1..11, fn i ->
          %{
            last_modified: System.system_time(:millisecond),
            name: "cve-2025-#{String.pad_leading(to_string(i), 5, "0")}.json",
            content: CVEJSON.valid(),
            size: byte_size(CVEJSON.valid()),
            content_type: "application/json"
          }
        end)

      file_input =
        index_live
        |> file_input("#upload-form", :raw_json, files)

      Enum.each(files, fn file ->
        render_upload(file_input, file.name)
      end)

      assert has_element?(
               index_live,
               ".alert.alert-error",
               "You have selected too many files"
             )

      assert index_live
             |> element("button[type='submit']")
             |> render()
             |> String.contains?("disabled")
    end
  end
end
