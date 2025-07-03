defmodule CveExplorer.Repo.Migrations.CreateCves do
  use Ecto.Migration

  def change do
    create table(:cves) do
      add :cve_id, :string, null: false, size: 30
      add :description, :text, null: false
      add :date_published, :utc_datetime, null: false
      add :date_updated, :utc_datetime, null: false
      add :raw_json, :map, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:cves, [:cve_id])
  end
end
