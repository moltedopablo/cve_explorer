defmodule CveExplorerWeb.APIController do
  use CveExplorerWeb, :controller

  alias CveExplorer.ThreatIntel

  action_fallback CveExplorerWeb.FallbackController

  def index(conn, _params) do
    cves = ThreatIntel.list_cves()
    render(conn, :index, cves: cves)
  end

  def raw_json(conn, %{"cve_id" => cve_id}) do
    with {:ok, cve} <- ThreatIntel.get_cve_by_cve_id(cve_id) do
      json(conn, cve.raw_json)
    end
  end
end
