defmodule CveExplorerWeb.CVELive.Index do
  use CveExplorerWeb, :live_view

  alias CveExplorer.ThreatIntel

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(:cves, ThreatIntel.list_cves())
     |> allow_upload(:raw_json, accept: ~w(.json), max_entries: 10)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Cves")
    |> assign(:cve, nil)
  end
end
