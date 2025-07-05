defmodule CveExplorerWeb.APIControllerTest do
  use CveExplorerWeb.ConnCase

  import CveExplorer.CveExplorerWebFixtures

  alias CveExplorer.CveExplorerWeb.CVE

  @create_attrs %{}
  @update_attrs %{}
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
end
