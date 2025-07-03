defmodule CveExplorer.ThreatIntel.CVE do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cves" do
    field :description, :string
    field :cve_id, :string
    field :date_published, :utc_datetime
    field :date_updated, :utc_datetime
    field :raw_json, :map

    timestamps(type: :utc_datetime)
  end

  @cve_regex ~r/^CVE-\d{4}-\d{4,19}$/
  @doc false
  def changeset(cve, attrs) do
    cve
    |> cast(attrs, [:cve_id, :description, :date_published, :date_updated, :raw_json])
    |> validate_required([:cve_id, :description, :date_published, :date_updated, :raw_json])
    |> validate_length(:cve_id, max: 30)
    |> validate_format(:cve_id, @cve_regex)
    |> unique_constraint(:cve_id)
  end
end
