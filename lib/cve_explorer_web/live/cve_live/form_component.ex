defmodule CveExplorerWeb.CVELive.FormComponent do
  use CveExplorerWeb, :live_component

  alias CveExplorer.ThreatIntel

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage cve records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="cve-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:cve_id]} type="text" label="Cve" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:date_published]} type="datetime-local" label="Date published" />
        <.input field={@form[:date_updated]} type="datetime-local" label="Date updated" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Cve</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{cve: cve} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(ThreatIntel.change_cve(cve))
     end)}
  end

  @impl true
  def handle_event("validate", %{"cve" => cve_params}, socket) do
    changeset = ThreatIntel.change_cve(socket.assigns.cve, cve_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"cve" => cve_params}, socket) do
    save_cve(socket, socket.assigns.action, cve_params)
  end

  defp save_cve(socket, :edit, cve_params) do
    case ThreatIntel.update_cve(socket.assigns.cve, cve_params) do
      {:ok, cve} ->
        notify_parent({:saved, cve})

        {:noreply,
         socket
         |> put_flash(:info, "Cve updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_cve(socket, :new, cve_params) do
    case ThreatIntel.create_cve(cve_params) do
      {:ok, cve} ->
        notify_parent({:saved, cve})

        {:noreply,
         socket
         |> put_flash(:info, "Cve created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
