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
       |> allow_upload(:raw_json, accept: ~w(.json), max_entries: 10),
       :cves,
       ThreatIntel.list_cves()
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
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
    processed_files =
      consume_uploaded_entries(socket, :raw_json, fn %{path: path}, entry ->
        with {:ok, content} <- File.read(path),
             {:ok, attrs} <- CVEParser.parse_cve(content),
             {:ok, %CVE{}} <- ThreatIntel.create_cve(attrs) do
          {:ok, {:ok, entry.client_name}}
        else
          {:error, reason} ->
            {:ok, {:error, {entry.client_name, format_file_error(reason)}}}
        end
      end)

    uploaded_files =
      Enum.map(processed_files, fn
        {:ok, file_name} ->
          %{file_name: file_name, status: :success}

        {:error, {file_name, error}} ->
          %{file_name: file_name, status: :error, error: format_file_error(error)}
      end)

    socket =
      socket
      |> assign(:uploaded_files, uploaded_files)
      |> stream(:cves, ThreatIntel.list_cves(), reset: true)

    {:noreply, socket}
  end

  defp format_file_error(%Jason.DecodeError{}) do
    "Invalid JSON format"
  end

  defp format_file_error(%Ecto.Changeset{errors: errors}) do
    Enum.map(errors, fn {field, {message, _}} ->
      "#{field} #{message}"
    end)
    |> Enum.join(". ")
  end

  defp format_file_error(error) when is_bitstring(error) do
    error
  end

  defp format_file_error(errors) when is_list(errors) do
    Enum.join(errors, ". ")
  end

  defp format_file_error(_error) do
    "There was an error processing the file"
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
