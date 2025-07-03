defmodule CveExplorerWeb.CVELiveTest do
  use CveExplorerWeb.ConnCase

  import Phoenix.LiveViewTest
  import CveExplorer.ThreatIntelFixtures

  @create_attrs %{description: "some description", cve_id: "some cve_id", date_published: "2025-07-02T15:24:00Z", date_updated: "2025-07-02T15:24:00Z", raw_json: %{}}
  @update_attrs %{description: "some updated description", cve_id: "some updated cve_id", date_published: "2025-07-03T15:24:00Z", date_updated: "2025-07-03T15:24:00Z", raw_json: %{}}
  @invalid_attrs %{description: nil, cve_id: nil, date_published: nil, date_updated: nil, raw_json: nil}

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

    test "saves new cve", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cves")

      assert index_live |> element("a", "New Cve") |> render_click() =~
               "New Cve"

      assert_patch(index_live, ~p"/cves/new")

      assert index_live
             |> form("#cve-form", cve: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cve-form", cve: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cves")

      html = render(index_live)
      assert html =~ "Cve created successfully"
      assert html =~ "some description"
    end

    test "updates cve in listing", %{conn: conn, cve: cve} do
      {:ok, index_live, _html} = live(conn, ~p"/cves")

      assert index_live |> element("#cves-#{cve.id} a", "Edit") |> render_click() =~
               "Edit Cve"

      assert_patch(index_live, ~p"/cves/#{cve}/edit")

      assert index_live
             |> form("#cve-form", cve: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cve-form", cve: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cves")

      html = render(index_live)
      assert html =~ "Cve updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes cve in listing", %{conn: conn, cve: cve} do
      {:ok, index_live, _html} = live(conn, ~p"/cves")

      assert index_live |> element("#cves-#{cve.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#cves-#{cve.id}")
    end
  end

  describe "Show" do
    setup [:create_cve]

    test "displays cve", %{conn: conn, cve: cve} do
      {:ok, _show_live, html} = live(conn, ~p"/cves/#{cve}")

      assert html =~ "Show Cve"
      assert html =~ cve.description
    end

    test "updates cve within modal", %{conn: conn, cve: cve} do
      {:ok, show_live, _html} = live(conn, ~p"/cves/#{cve}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Cve"

      assert_patch(show_live, ~p"/cves/#{cve}/show/edit")

      assert show_live
             |> form("#cve-form", cve: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#cve-form", cve: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/cves/#{cve}")

      html = render(show_live)
      assert html =~ "Cve updated successfully"
      assert html =~ "some updated description"
    end
  end
end
