defmodule CveExplorer.ThreatIntelTest do
  use CveExplorer.DataCase

  alias CveExplorer.ThreatIntel

  describe "cves" do
    alias CveExplorer.ThreatIntel.CVE

    import CveExplorer.ThreatIntelFixtures

    @invalid_attrs %{
      description: nil,
      cve_id: nil,
      date_published: nil,
      date_updated: nil,
      raw_json: nil
    }

    test "list_cves/0 returns all cves" do
      cve = cve_fixture()
      assert ThreatIntel.list_cves() == [cve]
    end

    test "get_cve!/1 returns the cve with given id" do
      cve = cve_fixture()
      assert ThreatIntel.get_cve!(cve.id) == cve
    end

    test "create_cve/1 with valid data creates a cve" do
      valid_attrs = %{
        description: "some description",
        cve_id: "some cve_id",
        date_published: ~U[2025-07-02 15:24:00Z],
        date_updated: ~U[2025-07-02 15:24:00Z],
        raw_json: %{}
      }

      assert {:ok, %CVE{} = cve} = ThreatIntel.create_cve(valid_attrs)
      assert cve.description == "some description"
      assert cve.cve_id == "some cve_id"
      assert cve.date_published == ~U[2025-07-02 15:24:00Z]
      assert cve.date_updated == ~U[2025-07-02 15:24:00Z]
      assert cve.raw_json == %{}
    end

    test "create_cve/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ThreatIntel.create_cve(@invalid_attrs)
    end
  end
end
