defmodule CveExplorerWeb.CVEControllerTest do
  use CveExplorerWeb.ConnCase

  import CveExplorer.CveExplorerWebFixtures

  alias CveExplorer.CveExplorerWeb.CVE

  @create_attrs %{

  }
  @update_attrs %{

  }
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all cves", %{conn: conn} do
      conn = get(conn, ~p"/api/cves")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create cve" do
    test "renders cve when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/cves", cve: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/cves/#{id}")

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/cves", cve: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update cve" do
    setup [:create_cve]

    test "renders cve when data is valid", %{conn: conn, cve: %CVE{id: id} = cve} do
      conn = put(conn, ~p"/api/cves/#{cve}", cve: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/cves/#{id}")

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, cve: cve} do
      conn = put(conn, ~p"/api/cves/#{cve}", cve: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete cve" do
    setup [:create_cve]

    test "deletes chosen cve", %{conn: conn, cve: cve} do
      conn = delete(conn, ~p"/api/cves/#{cve}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/cves/#{cve}")
      end
    end
  end

  defp create_cve(_) do
    cve = cve_fixture()
    %{cve: cve}
  end
end
