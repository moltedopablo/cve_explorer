defmodule CveExplorerWeb.APIJSON do
  alias CveExplorer.ThreatIntel.CVE

  @doc """
  Renders a list of cves.
  """
  def index(%{cves: cves}) do
    %{data: for(cve <- cves, do: data(cve))}
  end

  defp data(%CVE{} = cve) do
    %{
      cve_id: cve.cve_id,
      date_published: cve.date_published
    }
  end
end
