defmodule CveExplorerWeb.APIController do
  use CveExplorerWeb, :controller
  use PhoenixSwagger

  alias CveExplorer.ThreatIntel

  action_fallback CveExplorerWeb.FallbackController

  swagger_path :index do
    get("/api/cves")
    summary("List all CVEs")
    description("Retrieve a list of all CVE (Common Vulnerabilities and Exposures) entries")
    produces("application/json")
    response(200, "Success", Schema.ref(:CVEList))
  end

  def index(conn, _params) do
    cves = ThreatIntel.list_cves()
    render(conn, :index, cves: cves)
  end

  swagger_path :raw_json do
    get("/api/cves/{cve_id}")
    summary("Get CVE raw JSON data")
    description("Retrieve the raw JSON data for a specific CVE by its ID")
    produces("application/json")
    parameter(:cve_id, :path, :string, "CVE ID (e.g., CVE-2021-1234)", required: true)
    response(200, "Success", Schema.ref(:CVERawJSON))
    response(404, "CVE not found")
  end

  def raw_json(conn, %{"cve_id" => cve_id}) do
    with {:ok, cve} <- ThreatIntel.get_cve_by_cve_id(cve_id) do
      json(conn, cve.raw_json)
    end
  end

  def swagger_definitions do
    %{
      CVEList:
        swagger_schema do
          title("CVE List")
          description("A list of CVE entries")
          type(:array)
          items(Schema.ref(:CVE))
        end,
      CVE:
        swagger_schema do
          title("CVE")
          description("A CVE entry")
          type(:object)

          properties do
            cve_id(:string, "CVE id (e.g., CVE-2021-1234)")
            date_published(:string, "Publication date", format: :datetime)
          end
        end,
      CVERawJSON:
        swagger_schema do
          title("CVE Raw JSON")
          description("Raw JSON data for a CVE entry")
          type(:object)
        end
    }
  end
end
