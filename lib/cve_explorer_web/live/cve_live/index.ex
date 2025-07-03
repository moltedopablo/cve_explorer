defmodule CveExplorerWeb.CVELive.Index do
  use CveExplorerWeb, :live_view

  alias CveExplorer.ThreatIntel
  alias CveExplorer.ThreatIntel.CVE
  alias CveExplorer.CVEParser

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(
       socket
       |> assign(:uploaded_files, [])
       |> allow_upload(:raw_json, accept: ~w(.json), max_entries: 4),
       :cves,
       ThreatIntel.list_cves()
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Cve")
    |> assign(:cve, ThreatIntel.get_cve!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Cve")
    |> assign(:cve, %CVE{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Cves")
    |> assign(:cve, nil)
  end

  @impl true
  @spec handle_info(
          {CveExplorerWeb.CVELive.FormComponent, {:saved, any()}},
          Phoenix.LiveView.Socket.t()
        ) :: {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_info({CveExplorerWeb.CVELive.FormComponent, {:saved, cve}}, socket) do
    {:noreply, stream_insert(socket, :cves, cve)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    cve = ThreatIntel.get_cve!(id)
    {:ok, _} = ThreatIntel.delete_cve(cve)

    {:noreply, stream_delete(socket, :cves, cve)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :raw_json, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :raw_json, fn %{path: path}, entry ->
        IO.inspect(entry, label: "ENTRY")

        {:ok, %CVE{} = cve} = read_json(path) |> CVEParser.parse_cve() |> ThreatIntel.create_cve()
        # Move outside consume_uploaded_entries
        update(socket, :cves, fn cves -> [cve | cves] end)
        {:ok, entry.client_name}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  defp read_json(path) do
    {:ok, content} = File.read(path)
    content
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
