defmodule CveExplorerWeb.CVELive.Show do
  use CveExplorerWeb, :live_view

  alias CveExplorer.ThreatIntel

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:cve, ThreatIntel.get_cve!(id))}
  end

  @impl true
  def handle_event("download_cve", _params, socket) do
    cve = socket.assigns.cve
    json_content = Jason.encode!(cve.raw_json)
    filename = "#{cve.cve_id}.json"

    {:noreply,
     socket
     |> push_event("trigger_download", %{
       content: json_content,
       filename: filename,
       content_type: "application/json"
     })}
  end

  defp page_title(:show), do: "Show Cve"
end
