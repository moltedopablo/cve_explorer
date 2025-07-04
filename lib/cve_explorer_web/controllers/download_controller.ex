defmodule CveExplorerWeb.DownloadController do
  use CveExplorerWeb, :controller
  alias CveExplorer.ThreatIntel

  def download(conn, %{"id" => id}) do
    cve = ThreatIntel.get_cve!(id)
    json_content = Jason.encode!(cve.raw_json)

    send_download(
      conn,
      {:binary, json_content},
      content_type: "application/json",
      filename: "#{cve.cve_id}.json"
    )
  end
end
